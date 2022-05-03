# Modified and trimmed down version of Send-Key
# Uses scan codes instead of vk codes, which is mandatory for the game to recognize the input

# Tested only for arrow keys

Param (
    [Parameter(position=0, mandatory=$true, parametersetname='keyCode')]
    [Int16[]]$KeyCode
)

$code = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class KBEmulator {    
    public enum InputType : uint {
        INPUT_MOUSE = 0,
        INPUT_KEYBOARD = 1,
        INPUT_HARDWARE = 3
    }

    [Flags]
    internal enum KEYEVENTF : uint
    {
        KEYDOWN = 0x0,
        EXTENDEDKEY = 0x0001,
        KEYUP = 0x0002,
        SCANCODE = 0x0008,
        UNICODE = 0x0004,
    }

    [Flags]
    internal enum MOUSEEVENTF : uint
    {
        ABSOLUTE = 0x8000,
        HWHEEL = 0x01000,
        MOVE = 0x0001,
        MOVE_NOCOALESCE = 0x2000,
        LEFTDOWN = 0x0002,
        LEFTUP = 0x0004,
        RIGHTDOWN = 0x0008,
        RIGHTUP = 0x0010,
        MIDDLEDOWN = 0x0020,
        MIDDLEUP = 0x0040,
        VIRTUALDESK = 0x4000,
        WHEEL = 0x0800,
        XDOWN = 0x0080,
        XUP = 0x0100
    }

    // Master Input structure
    [StructLayout(LayoutKind.Sequential)]
    public struct lpInput {
        internal InputType type;
        internal InputUnion Data;
        internal static int Size { get { return Marshal.SizeOf(typeof(lpInput)); } }            
    }

    // Union structure
    [StructLayout(LayoutKind.Explicit)]
    internal struct InputUnion {
        [FieldOffset(0)]
        internal MOUSEINPUT mi;
        [FieldOffset(0)]
        internal KEYBDINPUT ki;
        [FieldOffset(0)]
        internal HARDWAREINPUT hi;
    }

    // Input Types
    [StructLayout(LayoutKind.Sequential)]
    internal struct MOUSEINPUT
    {
        internal int dx;
        internal int dy;
        internal int mouseData;
        internal MOUSEEVENTF dwFlags;
        internal uint time;
        internal UIntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct KEYBDINPUT
    {
        internal short wVk;
        internal short wScan;
        internal KEYEVENTF dwFlags;
        internal int time;
        internal UIntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct HARDWAREINPUT
    {
        internal int uMsg;
        internal short wParamL;
        internal short wParamH;
    }

    private class unmanaged {
        [DllImport("user32.dll", SetLastError = true)]
        internal static extern uint SendInput (
            int cInputs, 
            [MarshalAs(UnmanagedType.LPArray)]
            lpInput[] inputs,
            int cbSize
        );

        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern short VkKeyScan(char ch);
    }

    internal static byte[] VkKeyScan(char ch) {
        short keyCode = unmanaged.VkKeyScan(ch);
        if(keyCode > 254) {
            byte key = BitConverter.GetBytes(keyCode)[0];
            byte highByte = BitConverter.GetBytes(keyCode)[1];
            byte extraKey = 0;
            switch(highByte) {
                case 0x1:
                    extraKey = 0x10;  //VK_SHIFT
                    break;
                case 0x2:
                    extraKey = 0x11;  //VK_CONTROL
                    break;
                case 0x4:
                    extraKey = 0x12;  //VK_ALT
                    break;
            }
            byte[] rtn = new byte[] {extraKey, key};
            return rtn;
        } else {
            byte[] rtn = new byte[] {BitConverter.GetBytes(keyCode)[0]};
            return rtn;
        }

    }

    internal static uint SendInput(int cInputs, lpInput[] inputs, int cbSize) {
        return unmanaged.SendInput(cInputs, inputs, cbSize);
    }

    // Virtual KeyCodes: https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
    public static void SendKeyCode(Int16[] keyCode) {
        lpInput[] KeyInputs = new lpInput[keyCode.Length];

        for(int i = 0; i < keyCode.Length; i++) {
            lpInput KeyInput = new lpInput();
            // Generic Keyboard Event
            KeyInput.type = InputType.INPUT_KEYBOARD;
            KeyInput.Data.ki.wVk = 0;
            KeyInput.Data.ki.time = 0;
            KeyInput.Data.ki.dwExtraInfo = UIntPtr.Zero;

            // Push the correct key
            KeyInput.Data.ki.wScan = keyCode[i];
            KeyInput.Data.ki.dwFlags = KEYEVENTF.SCANCODE | KEYEVENTF.EXTENDEDKEY;
            KeyInputs[i] = KeyInput;
        }
        SendInput(keyCode.Length, KeyInputs, lpInput.Size);

        System.Threading.Thread.Sleep(50);

        // Release the key
        for(int i = 0; i < keyCode.Length; i++) {
            KeyInputs[i].Data.ki.dwFlags = KEYEVENTF.SCANCODE | KEYEVENTF.KEYUP | KEYEVENTF.EXTENDEDKEY;
        }
        SendInput(keyCode.Length, KeyInputs, lpInput.Size);

        return;
    }

    public static byte[] GetKeyCode(char ch) {
        return VkKeyScan(ch);
    }
}
"@

if(([System.AppDomain]::CurrentDomain.GetAssemblies() | ?{$_ -match "KBEmulator"}) -eq $null) {
    Add-Type -TypeDefinition $code
}

switch($PSCmdlet.ParameterSetName){
    'keyCode' { [KBEmulator]::SendKeyCode($KeyCode) }
}