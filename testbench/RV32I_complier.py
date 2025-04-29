class RV32IAssembler:
    def __init__(self):
        # Opcode map for RV32I base instruction set
        self.opcode_map = {
            'LUI': '0110111',
            'AUIPC': '0010111',
            'JAL': '1101111',
            'JALR': '1100111',
            'BEQ': '1100011',
            'BNE': '1100011',
            'BLT': '1100011',
            'BGE': '1100011',
            'BLTU': '1100011',
            'BGEU': '1100011',
            'LB': '0000011',
            'LH': '0000011',
            'LW': '0000011',
            'LBU': '0000011',
            'LHU': '0000011',
            'SB': '0100011',
            'SH': '0100011',
            'SW': '0100011',
            'ADDI': '0010011',
            'SLTI': '0010011',
            'SLTIU': '0010011',
            'XORI': '0010011',
            'ORI': '0010011',
            'ANDI': '0010011',
            'SLLI': '0010011',
            'SRLI': '0010011',
            'SRAI': '0010011',
            'ADD': '0110011',
            'SUB': '0110011',
            'SLL': '0110011',
            'SLT': '0110011',
            'SLTU': '0110011',
            'XOR': '0110011',
            'SRL': '0110011',
            'SRA': '0110011',
            'OR': '0110011',
            'AND': '0110011',
            'FENCE': '0001111',
            'ECALL': '1110011',
            'EBREAK': '1110011'
        }

        # Funct3 map for instructions requiring it
        self.funct3_map = {
            'BEQ': '000',
            'BNE': '001',
            'BLT': '100',
            'BGE': '101',
            'BLTU': '110',
            'BGEU': '111',
            'LB': '000',
            'LH': '001',
            'LW': '010',
            'LBU': '100',
            'LHU': '101',
            'SB': '000',
            'SH': '001',
            'SW': '010',
            'ADDI': '000',
            'SLTI': '010',
            'SLTIU': '011',
            'XORI': '100',
            'ORI': '110',
            'ANDI': '111',
            'SLLI': '001',
            'SRLI': '101',
            'SRAI': '101',
            'ADD': '000',
            'SUB': '000',
            'SLL': '001',
            'SLT': '010',
            'SLTU': '011',
            'XOR': '100',
            'SRL': '101',
            'SRA': '101',
            'OR': '110',
            'AND': '111',
            'JALR': '000'
        }

        # Funct7 map for R-type instructions
        self.funct7_map = {
            'ADD': '0000000',
            'SUB': '0100000',
            'SLL': '0000000',
            'SLT': '0000000',
            'SLTU': '0000000',
            'XOR': '0000000',
            'SRL': '0000000',
            'SRA': '0100000',
            'OR': '0000000',
            'AND': '0000000'
        }

    def register_to_binary(self, reg):
        """Convert register (e.g., x1) to 5-bit binary"""
        # print(reg)
        return f"{int(reg[1:]):05b}"

    def immediate_to_binary(self, imm, length):
        """Convert immediate to binary of specified length, handling sign and hexadecimal"""
        # print(type(imm))
        # print(imm)
        if isinstance(imm, str) and imm.startswith("0x"):
            imm = int(imm, 16)
        else:
            imm = int(imm)
        if imm < 0:
            imm = (1 << length) + imm
        return f"{imm:0{length}b}"

    def parse_offset_base(self, offset_base):
        """Parse offset(base) format into immediate and base register"""
        offset, base = offset_base.strip(')').split('(')
        return self.immediate_to_binary(offset, 12), self.register_to_binary(base)
    
    def format_binary(self, binary):
        """Format a binary string by adding underscores every four bits."""
        return '_'.join(binary[i:i+4] for i in range(0, len(binary), 4))

    def assemble(self, instruction):
        """Assemble a single RV32I instruction to binary"""
        print(instruction)
        parts = instruction.split()
        mnemonic = parts[0].upper()
        if mnemonic not in self.opcode_map:
            raise ValueError(f"Unsupported instruction: {mnemonic}")

        opcode = self.opcode_map[mnemonic]

        if opcode == '0110011':  # R-type
            rd = self.register_to_binary(parts[1].strip(','))
            rs1 = self.register_to_binary(parts[2].strip(','))
            rs2 = self.register_to_binary(parts[3])
            funct3 = self.funct3_map[mnemonic]
            funct7 = self.funct7_map[mnemonic]
            return f"{funct7}{rs2}{rs1}{funct3}{rd}{opcode}"

        elif opcode == '0010011':  # I-type
            rd = self.register_to_binary(parts[1].strip(','))
            rs1 = self.register_to_binary(parts[2].strip(','))
            if mnemonic == 'SRAI':
                imm = f"0100000{self.immediate_to_binary(parts[3], 5)}"  # Set imm[11:5] to 0100000
            else:
                imm = self.immediate_to_binary(parts[3], 12)
            funct3 = self.funct3_map[mnemonic]
            return f"{imm}{rs1}{funct3}{rd}{opcode}"

        elif opcode == '0000011':  # Load instructions
            rd = self.register_to_binary(parts[1].strip(','))
            imm, rs1 = self.parse_offset_base(parts[2])
            funct3 = self.funct3_map[mnemonic]
            return f"{imm}{rs1}{funct3}{rd}{opcode}"

        elif opcode == '1100111':  # JALR (I-type)
            rd = self.register_to_binary(parts[1].strip(','))
            rs1 = self.register_to_binary(parts[2].strip(','))
            imm = self.immediate_to_binary(parts[3], 12)
            funct3 = self.funct3_map[mnemonic]
            return f"{imm}{rs1}{funct3}{rd}{opcode}"

        elif opcode == '1100011':  # B-type
            rs1 = self.register_to_binary(parts[1].strip(','))
            rs2 = self.register_to_binary(parts[2].strip(','))
            imm = self.immediate_to_binary(parts[3], 13)
            funct3 = self.funct3_map[mnemonic]
            imm_bin = f"{imm[0]}{imm[2:8]}{imm[8:12]}{imm[1]}"
            return f"{imm_bin[:7]}{rs2}{rs1}{funct3}{imm_bin[7:]}{opcode}"

        elif opcode == '0100011':  # S-type
            rs2 = self.register_to_binary(parts[1].strip(','))
            imm, rs1 = self.parse_offset_base(parts[2])
            funct3 = self.funct3_map[mnemonic]
            return f"{imm[:7]}{rs2}{rs1}{funct3}{imm[7:]}{opcode}"

        elif opcode in ['0110111', '0010111']:  # U-type (LUI, AUIPC)
            rd = self.register_to_binary(parts[1].strip(','))
            imm = self.immediate_to_binary(parts[2], 20)
            return f"{imm}{rd}{opcode}"

        elif opcode == '1101111':  # J-type (JAL)
            rd = self.register_to_binary(parts[1].strip(','))
            imm = self.immediate_to_binary(parts[2], 21)
            imm_bin = f"{imm[0]}{imm[10:20]}{imm[9]}{imm[1:9]}"
            return f"{imm_bin}{rd}{opcode}"

        else:
            raise NotImplementedError(f"Assembler for {mnemonic} not implemented")

    def assemble_from_file(self, file_path):
        """Read instructions from a file and assemble them with labels"""
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()

        memory = []
        label_map = {}
        address = 0

        # First pass: collect labels and their addresses
        for line in lines:
            instruction = line.split('#')[0].strip()  # Remove comments
            if not instruction:
                continue
            if instruction.endswith(':'):  # It's a label
                label = instruction[:-1]
                label_map[label] = address
            else:
                memory.append(instruction)  # Add non-label instructions to memory
                address += 1  # Each instruction is 4 bytes (32 bits)
        # print(label_map)

        binaries = []
        address = 0

        # Second pass: assemble instructions
        for instruction in memory:
            parts = instruction.split()
            mnemonic = parts[0].upper()

            # Check for branch or JAL instructions and calculate immediate
            if mnemonic in ['BEQ', 'BNE', 'BLT', 'BGE', 'BLTU', 'BGEU', 'JAL']:
                label = parts[-1]  # Last part is the label
                target_address = label_map[label]
                # print(address)
                offset = (target_address - address)  # Offset in instructions
                parts[-1] = str(offset)  # Replace label with calculated offset

            # Assemble the instruction and add it to binaries
            binary = self.assemble(' '.join(parts))
            binaries.append(self.format_binary(binary))
            # binaries.append(binary)
            address += 1

        return binaries


# Example usage
assembler = RV32IAssembler()
file_path = "fibonacci.txt"  # File containing instructions
binaries = assembler.assemble_from_file(file_path)
for binary in binaries:
    print(binary)
    
try:
    # Open the file in write mode
    with open('machine code fibonacci.txt', 'w') as file:
        for binary in binaries:
            file.write(f"{binary}\n")
except IOError as e:
    print(f"An error occurred while writing to the file: {e}")