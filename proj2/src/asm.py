#! /usr/bin/env python

import re
import sys


class SaveList(list):
    def __init__(self, lst):
        super(SaveList, self).__init__(lst)

    def get(self, index, default=None):
        if index < list.__len__(self):
            return list.__getitem__(self, index)
        else:
            return default



def to_binary(number, width):
    neg_flag = False
    if number < 0:
        neg_flag = True
        number *= -1
    ret = ('{0:0>%db}' % width).format(number)
    if neg_flag:
        ret = ['1' if c == '0' else '0' for c in ret]
        for i in range(len(ret) - 1, -1, -1):
            if ret[i] == '0':
                ret[i] = '1'
                break
            else:
                ret[i] = '0'
        ret = ''.join(ret)
    return ret


def num(value, base=0):
    if isinstance(value, (int, long)):
        return value
    if base > 0:
        return int(value, base)
    elif value.startswith('0x'): return int(value[2 : ], 16)
    elif value.startswith('0b'): return int(value[2 : ], 2)
    elif value.startswith('b'): return int(value[1 : ], 2)
    elif value.startswith('0') and len(value) > 1: return int(value[1 : ], 8)
    else: return int(value)


def reg_num(name):
    if not name.startswith('$'):
        raise ValueError('Register name "%s" should starts with "$".' % name)
    name = name[1 : ]
    if str.isdigit(name) and 0 <= int(name) <= 31: return int(name)
    elif name == 'zero': return 0
    elif name == 'at': return 1
    elif name == 'gp': return 28
    elif name == 'sp': return 29
    elif name == 'fp': return 30
    elif name == 'ra': return 31
    else:
        value = int(name[1 : ])
        if name[0] == 'v' and 0 <= value <= 1: return 2 + value
        elif name[0] == 'a' and 0 <= value <= 3: return 4 + value
        elif name[0] == 't' and 0 <= value <= 7: return 8 + value
        elif name[0] == 's' and 0 <= value <= 7: return 16 + value
        elif name[0] == 't' and 8 <= value <= 9: return 24 + value - 8
        elif name[0] == 'k' and 0 <= value <= 1: return 26 + value
        else:
            raise ValueError('Wrong format: %r' % ('$' + name))

def reg_str(number):
    if number == 0: return '$zero'
    elif number == 1: return '$at'
    elif number == 28: return '$gp'
    elif number == 29: return '$sp'
    elif number == 30: return '$fp'
    elif number == 31: return '$ra'
    elif 2 <= number <= 3: return '$v%d' % (number - 2)
    elif 4 <= number <= 7: return '$a%d' % (number - 4)
    elif 8 <= number <= 15: return '$t%d' % (number - 8)
    elif 16 <= number <= 23: return '$s%d' % (number - 16)
    elif 24 <= number <= 25: return '$t%d' % (number - 16)
    elif 26 <= number <= 27: return '$k%d' % (number - 26)

labels = {}

def addr_num(address):
    if isinstance(address, (int, long)):
        return address
    if address not in labels:
        raise ValueError('Unknown label name %r.' % address)
    return labels[address]


class RTypeInstr(object):
    def __init__(self, opcode, rs, rt, rd, shift, funct):
        super(RTypeInstr, self).__init__()
        self._opcode = opcode
        self._rs = rs
        self._rt = rt
        self._rd = rd
        self._shift = shift
        self._funct = funct

    def encode(self, splitter = '_'):
        return splitter.join([to_binary(self._opcode, 6),
                              to_binary(self._rs, 5),
                              to_binary(self._rt, 5),
                              to_binary(self._rd, 5),
                              to_binary(self._shift, 5),
                              to_binary(self._funct, 6)])

    def comment(self, cmd):
        return '%s %s, %s, %s' % (
            cmd, reg_str(self._rd), reg_str(self._rs), reg_str(self._rt))

class AddInstr(RTypeInstr):
    def __init__(self, pc, rd, rs, rt, *_):
        super(AddInstr, self).__init__(num('0b000000'),
                                       reg_num(rs), reg_num(rt), reg_num(rd),
                                       0,
                                       num('0b100000'))

    def comment(self):
        return super(AddInstr, self).comment('add')

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'add'

class SubInstr(RTypeInstr):
    def __init__(self, pc, rd, rs, rt, *_):
        super(SubInstr, self).__init__(num('0b000000'),
                                       reg_num(rs), reg_num(rt), reg_num(rd),
                                       0,
                                       num('0b100010'))

    def comment(self):
        return super(SubInstr, self).comment('sub')

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'sub'

class AndInstr(RTypeInstr):
    def __init__(self, pc, rd, rs, rt, *_):
        super(AndInstr, self).__init__(num('0b000000'),
                                       reg_num(rs), reg_num(rt), reg_num(rd),
                                       0,
                                       num('0b100100'))

    def comment(self):
        return super(AndInstr, self).comment('and')

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'and'

class OrInstr(RTypeInstr):
    def __init__(self, pc, rd, rs, rt, *_):
        super(OrInstr, self).__init__(num('0b000000'),
                                      reg_num(rs), reg_num(rt), reg_num(rd),
                                      0,
                                      num('0b100101'))

    def comment(self):
        return super(OrInstr, self).comment('or')

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'or'

class MulInstr(RTypeInstr):
    def __init__(self, pc, rd, rs, rt, *_):
        super(MulInstr, self).__init__(num('0b000000'),
                                       reg_num(rs), reg_num(rt), reg_num(rd),
                                       0,
                                       num('0b011000'))

    def comment(self):
        return super(MulInstr, self).comment('mul')

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'mul'


class ITypeInstr(object):
    def __init__(self, opcode, rs, rt, immed):
        super(ITypeInstr, self).__init__()
        self._opcode = opcode
        self._rs = rs
        self._rt = rt
        self._immed = immed

    def encode(self, splitter = '_'):
        return splitter.join([to_binary(self._opcode, 6),
                              to_binary(self._rs, 5), to_binary(self._rt, 5),
                              to_binary(self._immed, 16)])

    def comment(self, cmd):
        return '%s %s, %s, %d' % (
            cmd, reg_str(self._rt), reg_str(self._rs), self._immed)

    @property
    def rs(self):
        return self._rs

    @property
    def rt(self):
        return self._rt

    @property
    def immed(self):
        return self._immed

class AddiInstr(ITypeInstr):
    def __init__(self, pc, rd, rs, const, *_):
        super(AddiInstr, self).__init__(
            num('0b001000'), reg_num(rs), reg_num(rd), num(const))

    def comment(self):
        return super(AddiInstr, self).comment('addi')

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'addi'

class LwInstr(ITypeInstr):
    def __init__(self, pc, rd, offset, rs, *_):
        super(LwInstr, self).__init__(
            num('0b100011'), reg_num(rs), reg_num(rd), num(offset))

    def comment(self):
        return super(LwInstr, self).comment('lw')

    def comment(self):
        return 'lw %s %d(%s)' % (reg_str(self.rt), self.immed, reg_str(self.rs))

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'lw'

class SwInstr(ITypeInstr):
    def __init__(self, pc, rd, offset, rs, *_):
        super(SwInstr, self).__init__(
            num('0b101011'),reg_num(rs), reg_num(rd), num(offset))

    def comment(self):
        return 'sw %s %d(%s)' % (reg_str(self.rt), self.immed, reg_str(self.rs))

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'sw'

class BeqInstr(ITypeInstr):
    def __init__(self, pc, rs, rt, address, *_):
        dest = (addr_num(address) - (pc + 4)) / 4
        super(BeqInstr, self).__init__(
            num('0b000100'), reg_num(rs), reg_num(rt), dest)

    def comment(self):
        return 'beq %s %s %d' % (reg_str(self.rs), reg_str(self.rt), self.immed)

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'beq'


class JTypeInstr(object):
    def __init__(self, opcode, address):
        super(JTypeInstr, self).__init__()
        self._opcode = opcode
        self._address = address

    def encode(self, splitter = '_'):
        return splitter.join([to_binary(self._opcode, 6),
                              to_binary(self._address, 26)])

    def comment(self, cmd):
        return '%s %d' % (cmd, self._address)

class JInstr(JTypeInstr):
    def __init__(self, pc, address, *_):
        dest = addr_num(address) / 4
        super(JInstr, self).__init__(num('0b000010'), dest)

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'j'

    def comment(self):
        return super(JInstr, self).comment('j')


class NopInstr(object):
    def __init__(self, *args):
        pass

    def encode(self, splitter = '_'):
        return '00000000000000000000000000000000'

    def comment(self):
        return 'nop'

    @staticmethod
    def is_my_command(cmd):
        return cmd.lower() == 'nop'


all_instrs = [AddInstr,
              SubInstr,
              AndInstr,
              OrInstr,
              MulInstr,
              AddiInstr,
              LwInstr,
              SwInstr,
              BeqInstr,
              JInstr,
              NopInstr]


def main():
    if not (2 <= len(sys.argv) <= 3):
        print '[USAGE]'
        print '    %r <input_filename> [<output_filename>]' % sys.argv[0]
        print ''
        print 'If the <output_filename> is not specified, this program will'
        print 'print the result to the stdout.'
        return 1

    input_filename = sys.argv[1]

    lines = []
    f = open(input_filename, 'r')
    lines = f.readlines()
    for i in range(len(lines)):
        if lines[i].endswith('\n'):
            lines[i] = lines[i][ : -1]
    f.close()

    wordss = [SaveList(word for word in re.split(r'[ \t,()]', line) if word)
              for line in lines]

    result = []
    pc = 0
    for words in list(wordss):
        if words.get(0, '').endswith(':'):
            label_name = words[0][ : -1]
            if label_name in labels:
                print 'Label name conflict: %r' % label_name
                return 1
            labels[label_name] = pc
            del words[0]
        if not words or words.get(0, '').startswith('#'):
            wordss.remove(words)
        else:
            pc += 4

    instrs = []
    pc = 0
    for words in wordss:
        for try_instr in all_instrs:
            if try_instr.is_my_command(words[0]):
                try:
                    instr = try_instr(pc, *(words[1 : ] + [None]))
                except Exception, e:
                    print 'At the statement %r' % ' '.join(words)
                    print 'Exception cought: %r' % e
                    return 1;
                break
        else:
            print 'Unknown statement: %r' % ' '.join(words)
            return 1
        pc += 4
        instrs.append(instr)

    ouf = open(sys.argv[2], 'w') if len(sys.argv) == 3 else sys.stdout

    maxlen = max(len(instr.encode()) for instr in instrs)
    pc = 0
    for instr in instrs:
        ouf.write(('%-' + str(maxlen) + 's  // (PC=%2d)  %s\n') % (
            instr.encode(), pc, instr.comment()))
        pc += 4

    ouf.close()

    return 0


if __name__ == '__main__':
    sys.exit(main())
