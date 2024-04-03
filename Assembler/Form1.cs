using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Reflection.Emit;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Assembler
{
    public partial class Assembler : Form
    {
        // The instruction type is the main token in a given instruction and should be known the first token in an instruction (first word)
        enum InstType
        {
            itype, rtype, lui, load, store, j, jal, branch, jalr, invalid_Inst, hlt
        }

        // the opcodes is a dictionary the you give it a certain opcode (in words) and get beack the binaries (or machine code) corresponding to that opcode
        // take a look to know what to expect because the binary might be different depending on the opcode some of them only opcode or with func3 or even with func7
        static Dictionary<string, string> opcodes = new Dictionary<string, string>()
        {
            { "j"       , "1100111" },
            { "jal"     , "1101111" },

            { "beq"     , "0001100011" },
            { "bne"     , "0011100011" },
            { "blt"     , "1001100011" },
            { "bge"     , "1011100011" },
            { "bltu"    , "1101100011" },
            { "bgeu"    , "1111100011" },

            { "jalr"    , "0001101011" },

            { "lw"      , "0100000011" },
            { "sw"      , "0100100011" },

            { "addi"    , "0000010011" },
            { "slli"    , "0010010011" },
            { "slti"    , "0100010011" },
            { "sltiu"   , "0110010011" },
            { "xori"    , "1000010011" },
            { "srli"    , "1010010011" },
            { "ori"     , "1100010011" },
            { "andi"    , "1110010011" },

            { "add"     , "00000000000110011" },
            { "sub"     , "10000000000110011" },
            { "sll"     , "00000000010110011" },
            { "slt"     , "00000000100110011" },
            { "sltu"    , "00000000110110011" },
            { "xor"     , "00000001000110011" },
            { "srl"     , "00000001010110011" },
            { "or"      , "00000001100110011" },
            { "and"     , "00000001110110011" },

            { "lui"     , "0110111" },
        };

        static Dictionary<string, int> labels = new Dictionary<string, int>();

        // the invInst is a string that come up when an invalid instruction is entered from the user
        static string invinst = "Invalid Instruction";
        static string invlbl = "Invalid Label";

        public Assembler()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        // checks for impty instruction that dont need to be tokenized or converted to machine code
        public static bool EmptyLine(string instruction)
        {
            return string.IsNullOrEmpty(instruction) || string.IsNullOrWhiteSpace(instruction);
        }

        // input : the opcode (string : in words)
        // return the Instruction type
        InstType GetInstType(string name)
        {
            switch (name)
            {
                case "j":
                    return InstType.j;
                case "jal":
                    return InstType.jal;
                case "beq":
                case "bne":
                case "blt":
                case "bge":
                case "bltu":
                case "bgeu":
                    return InstType.branch;
                case "jalr":
                    return InstType.jalr;
                case "lw":
                    return InstType.load;
                case "sw":
                    return InstType.store;
                case "addi":
                case "slli":
                case "slti":
                case "sltiu":
                case "xori":
                case "srli":
                case "ori":
                case "andi":
                    return InstType.itype;
                case "add":
                case "sub":
                case "sll":
                case "slt":
                case "sltu":
                case "xor":
                case "srl":
                case "or":
                case "and":
                    return InstType.rtype;
                case "lui":
                    return InstType.lui;
                case "hlt":
                    return InstType.hlt;
                default:
                    return InstType.invalid_Inst;
            }
        }

        // it takes as input the register name and extracts the index form it
        string getregindex(string reg)
        {
            if (!reg.StartsWith("x"))
                return invinst;
            string index = reg.Substring(1);



            if (byte.TryParse(index, out byte usb) && usb >=0 && usb <= 31)
            {

                index = Convert.ToString(usb, 2);
                while (index.Length < 5)
                    index = "0" + index;
            }
            else
                return invinst;

            index = index.Substring(index.Length - 5);

            return index;
        }

        // the following functions are used to tokenize, parse, and then generate the corresponding machine code for every 
        // token of the instruction
        string Getjumpinst(List<string> inst)
        {
            if (inst.Count != 2 || !labels.ContainsKey(inst[1])) return invinst;
            // here the immed is the label type by the programmer we want to convert it to an actual immediate
            string immed = inst[1]; 

            immed = (labels[immed] - curr_inst_index).ToString();

            if (uint.TryParse(immed, out uint sb))
            {
                immed = Convert.ToString(sb, 2);
                while (immed.Length < 25)
                    immed = "0" + immed;
            }

            else if (int.TryParse(immed, out int usb))
            {
                immed = Convert.ToString(usb, 2);
                while (immed.Length < 25)
                    immed = immed[0] + immed;

            }
            else
                return invinst;

            immed = immed.Substring(immed.Length - 25);

            string mc = immed + opcodes[inst[0]];
            return mc;
        }

        string getbranchinst(List<string> inst)
        {
            if (inst.Count != 4 || !labels.ContainsKey(inst[3])) return invinst;
            string immed = inst[3];

            immed = (labels[immed] - curr_inst_index).ToString();

            if (ushort.TryParse(immed, out ushort usb))
            {
                immed = Convert.ToString(usb, 2);
                while (immed.Length < 12)
                    immed = "0" + immed;
            }
            else if (short.TryParse(immed, out short sb))
            {
                immed = Convert.ToString(sb, 2);
                while (immed.Length < 12)
                    immed = immed[0] + immed;
            }
            else
                return invinst;

            immed = immed.Substring(immed.Length - 12);


            string rs1 = getregindex(inst[1]);
            string rs2 = getregindex(inst[2]);
            if (rs1 == invinst || rs2 == invinst) return invinst;

            string mc = immed.Substring(0, 5) + 
                        rs1 +  
                        rs2 + 
                        immed.Substring(5) + 
                        opcodes[inst[0]];
            return mc;
        }

        string getjalrinst(List<string> inst)
        {
            if (inst.Count != 4) 
                return invinst;

            string immed = inst[3];

            if (ushort.TryParse(immed, out ushort usb))
            {
                immed = Convert.ToString(usb, 2);
                while (immed.Length < 12)
                    immed = "0" + immed;
            }
            else if (short.TryParse(immed, out short sb))
            {
                immed = Convert.ToString(sb, 2);
                while (immed.Length < 12)
                    immed = immed[0] + immed;
            }
            else
                return invinst;

            immed = immed.Substring(immed.Length - 12);
            string rd  = getregindex(inst[1]);
            string rs1 = getregindex(inst[2]);
            if (rd == invinst || rs1 == invinst) return invinst;

            string mc = rd + rs1 + immed + opcodes[inst[0]];
            return mc;
        }

        string getloadinst(List<string> inst)
        {
            if (inst.Count != 4) return invinst;
            string immed = inst[3];

            if (ushort.TryParse(immed, out ushort usb))
            {
                immed = Convert.ToString(usb, 2);
                while (immed.Length < 12)
                    immed = "0" + immed;
            }
            else if (short.TryParse(immed, out short sb))
            {
                immed = Convert.ToString(sb, 2);
                while (immed.Length < 12)
                    immed = immed[0] + immed;
            }
            else
                return invinst;

            immed = immed.Substring(immed.Length - 12);
            string rd = getregindex(inst[1]);
            string rs1 = getregindex(inst[2]);
            if (rd == invinst || rs1 == invinst) return invinst;

            string mc = rd + rs1 + immed + opcodes[inst[0]];
            return mc;
        }

        string getstoreinst(List<string> inst)
        {
            if (inst.Count != 4) return invinst;
            string immed = inst[3];

            if (ushort.TryParse(immed, out ushort usb))
            {
                immed = Convert.ToString(usb, 2);
                while (immed.Length < 12)
                    immed = "0" + immed;
            }
            else if (short.TryParse(immed, out short sb))
            {
                immed = Convert.ToString(sb, 2);
                while (immed.Length < 12)
                    immed = immed[0] + immed;
            }
            else
                return invinst;

            immed = immed.Substring(immed.Length - 12);
            string rs1 = getregindex(inst[1]);
            string rs2 = getregindex(inst[2]);
            if (rs1 == invinst || rs2 == invinst) return invinst;

            string mc = immed.Substring(0,5) + rs1 + rs2 +
                        immed.Substring(5) + opcodes[inst[0]];
            return mc;
        }

        string getrtypeinst(List<string> inst)
        {
            if (inst.Count != 4) return invinst;

            string rd  = getregindex(inst[1]);
            string rs1 = getregindex(inst[2]);
            string rs2 = getregindex(inst[3]);
            if (rd == invinst || rs1 == invinst || rs2 == invinst) return invinst;

            return rd + rs1 + rs2 + opcodes[inst[0]];
        }

        string getluiinst(List<string> inst)
        {
            if (inst.Count != 3) return invinst;
            string immed = inst[2];

            if (uint.TryParse(immed, out uint usb))
            {
                immed = Convert.ToString(usb, 2);
                while (immed.Length < 20)
                    immed = "0" + immed;
            }
            else if (int.TryParse(immed, out int sb))
            {
                immed = Convert.ToString(sb, 2);
                while (immed.Length < 20)
                    immed = immed[0] + immed;
            }
            else
                return invinst;

            immed = immed.Substring(immed.Length - 20);
            string rd = getregindex(inst[1]);
            if (rd == invinst) return invinst;

            string mc = rd + immed + opcodes[inst[0]];
            return mc;
        }

        string getitypeinst(List<string> inst)
        {
            if (inst.Count != 4) return invinst;
            string mc = "";
            string immed = inst[3];
            if (inst[0] == "slli" || inst[0] == "srli")
            {
                if (byte.TryParse(immed, out byte usb))
                {
                    immed = Convert.ToString(usb, 2);
                    while (immed.Length < 6)
                        immed = "0" + immed;
                }
                else
                    return invinst;

                
                immed = immed.Substring(immed.Length - 6);
                string rd = getregindex(inst[1]);
                string rs1 = getregindex(inst[2]);
                if (rd == invinst || rs1 == invinst) return invinst;

                mc = rd + rs1 + "000000" + immed + opcodes[inst[0]];
            }

            else
            {
                if (ushort.TryParse(immed, out ushort usb))
                {
                    immed = Convert.ToString(usb, 2);
                    while (immed.Length < 12)
                        immed = "0" + immed;
                }
                else if (short.TryParse(immed, out short sb))
                {
                    immed = Convert.ToString(sb, 2);
                    while (immed.Length < 12)
                        immed = immed[0] + immed;
                }
                else
                    return invinst;
                
                immed = immed.Substring(immed.Length - 12);
                string rd = getregindex(inst[1]);
                string rs1 = getregindex(inst[2]);
                if (rd == invinst || rs1 == invinst) return invinst;

                mc = rd + rs1 + immed + opcodes[inst[0]];
            }

            return mc;
        }

        string gethltinst(List<string> inst)
        {
            if (inst.Count != 1) return invinst;

            return "00000000000000000000000001111111";
        }

        // this function takes the instructio and it's type and based on it, it passes it to the suitable fucntion to generate the machine code
        string GetMcOfInst(InstType type, List<string> inst)
        {
            // here we construct the binaries of a given instruction
            switch (type)
            {
                case InstType.j:
                case InstType.jal:
                    return Getjumpinst(inst);
                case InstType.branch:
                    return getbranchinst(inst);
                case InstType.jalr:
                    return  getjalrinst(inst);
                case InstType.load:
                    return getloadinst(inst);
                case InstType.store:
                    return getstoreinst(inst);
                case InstType.itype:
                    return getitypeinst(inst);
                case InstType.rtype:
                    return getrtypeinst(inst);
                case InstType.lui:
                    return getluiinst(inst);
                case InstType.hlt:
                    return gethltinst(inst);
                case InstType.invalid_Inst:
                    return invinst;
            }

            return "";
        }


        private int curr_inst_index;
        // this fucntion iterates through the whole list of instruction and returns a list of the machine code for each valid instruction
        // and keep track of it's index for substituting the values of the labels
        List<string> GetMachineCode(List<List<string>> insts)
        {
            List<string> mc = new List<string>();
            curr_inst_index = 0;
            foreach (List<string> inst in insts)
            {
                mc.Add(GetMcOfInst(GetInstType(inst[0]), inst));
                curr_inst_index++;
            }

            return mc;
        }


        // assmebling the program starts form here 
        // it tokenizes each non empty instruction and returns a list of parsable instruction each one of them is a list of tokens
        private List<List<string>> Tokenize(List<string> thecode)
        {
            List<List<string>> insts = new List<List<string>>();
            foreach (string line in thecode)
            {
                List<string> curr_inst = new List<string>();
                int i = 0;
                contin:
                string token = "";
                while (i < line.Length && line[i] != ' ' && line[i] != ',')
                    token += line[i++];

                
                if (!EmptyLine(token))
                {
                    if (token.Length > 1 && token[0] == '/' && token[1] == '/')
                        continue;
                    curr_inst.Add(token.ToLower());
                }
                while (i < line.Length && (line[i] == ' ' || line[i] == ',')) i++;

                if (i < line.Length) goto contin;
                
                if (curr_inst.Count != 0) insts.Add(curr_inst);
            }

            subtitute_labels(insts);

            return insts;
        }

        // it checks if a given label is valid or not
        private string Is_valid_label(List<string> label)
        {
            if (label.Count == 1 && label[0].Count(x => x == ':') == 1)
                return label[0].Remove(label[0].IndexOf(':'));

            else if (label.Count == 2 && !label[0].Contains(":") && label[1] == ":")
                return label[0];

            return invlbl;
        }

        // this funciton saves each label and it's value (address) so it can be used when computing the offset address in the jump and branch instructions
        private void subtitute_labels(List<List<string>> insts)
        {
            int index = 0;
            for (int i = 0; i < insts.Count; i++)
            {
                if (insts[i].Any(str => str.Contains(":")))
                {
                    string label = Is_valid_label(insts[i]);
                    lblinvlabel.Visible = label == invlbl;
                    if (label != invlbl)
                    {
                        if (labels.ContainsKey(label))
                            lblmultlabels.Visible = true;
                        else
                        {
                            labels.Add(label, index);
                            lblmultlabels.Visible = false;
                        }
                    }
                }
                else
                    index++;
            }

            // it removes any label from the list of instructions
            insts.RemoveAll(x => x.Any(y => y.Contains(':')));
        }

        // here we write on the output the machine code and it's hex value for easy use ane readability
        private void format_insts_list(List<string> insts_list)
        {
            for (int i = 0; i < insts_list.Count; i++)
            {
                if (insts_list[i].Contains(invinst)) continue;

                uint num = Convert.ToUInt32(insts_list[i], 2);
                string hex = num.ToString("X");
                while (hex.Length < 8) hex = "0" + hex;
                insts_list[i] += " / " + num.ToString() + " / " + hex;
            }
        }


        // this is the entry point of the entire process because we want to process the input only if the input is changed
        private void Input_TextChanged(object sender, EventArgs e)
        {
            labels.Clear();
            List<string> thecode = input.Lines.ToList();
            List<List<string>> insts = new List<List<string>>();


            insts = Tokenize(thecode);
            // here we have a list of instructions that we can genrate machine code for


            if (insts.Count != 0)
            {
                List<string> insts_list = GetMachineCode(insts);

                format_insts_list(insts_list);

                int size = insts_list.Count;
                List<string> tb_inst = new List<string>();
                for (int i = 0; i < size; i++)
                {
                    if (insts_list[i].Contains(invinst))
                        tb_inst.Add(invinst);
                    else
                        tb_inst.Add($"PC1 = {i}; Inst_to_wr = 32'h{insts_list[i].Substring(insts_list[i].Length - 8)}; #2; ");
                }

                // List<string> outputed_insts = GetInstfromMC(insts_list);

                lblnumofinst.Text = insts_list.Count.ToString();
                insts_list.AddRange(tb_inst);
                output.Lines = insts_list.ToArray();

                lblinvinst.Visible = insts_list.Any(x => x.Contains(invinst));
            }
            else
            {
                output.Lines = new List<string>().ToArray();
                lblnumofinst.Text = "0";
                lblinvinst.Visible = false;
            }
        }

        // this function is available to convert a given machine to an instruction that is easy to read and manipulate
        //private string MC_to_Inst(string mc)
        //{
        //    string inst = "";
        //    string opcode_func3 = mc.Substring(mc.Length - 10);


        //    return inst;
        //}

        //private List<string> GetInstfromMC(List<string> insts_list)
        //{
        //    List<string> res = new List<string>();
        //    foreach (string mc in insts_list)
        //    {
        //        res.Add(MC_to_Inst(mc));
        //    }

        //    return res;
        //}
    }
}
