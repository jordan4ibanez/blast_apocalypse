-- this is from: https://stackoverflow.com/questions/48093429/determine-whether-lua-compiler-runs-32-or-64-bit
-- converted into a function

-- simple function to detect the program's architecture, 32 or 64 bit
function detect_architecture()
    local arch
    -- detect OS
    if (os.getenv"os" or ""):match"^Windows" then
        arch = os.getenv"PROCESSOR_ARCHITECTURE"
    else
        arch = io.popen"uname -m":read"*a"
    end
    -- detect architecture
    if (arch or ""):match"64" then
        return(64)
    else
        return(32)
    end
end