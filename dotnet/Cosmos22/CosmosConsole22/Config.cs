// Chris Joakim, Microsoft, August 2021

namespace CosmosConsole22{

    using System;
    using Newtonsoft.Json;
    using DocumentFormat.OpenXml.Wordprocessing;

    /**
     * This class is the source of all configuration values for this application -  
     * including environment variables and command-line arguments.  It does this 
     * to support either command-line/terminal/shell or Docker container execution.   
     * With Docker, the command-line can be passed in as environment variable 'CLI_ARGS_STRING'.
     */
    public class Config{
        // Constants; environment variable names:
        public const string AZURE_DEMO22_REPO_DIR_MAC                = "AZURE_DEMO22_REPO_DIR_MAC";
        public const string AZURE_DEMO22_REPO_DIR_WIN                = "AZURE_DEMO22_REPO_DIR_WIN";
        public const string AZURE_DEMO22_REPO_DIR_LINUX              = "AZURE_DEMO22_REPO_DIR_LINUX";
        public const string AZURE_DEMO22_COSMOSDB_SQLDB_ACCT         = "AZURE_DEMO22_COSMOSDB_SQLDB_ACCT";
        public const string AZURE_DEMO22_COSMOSDB_SQLDB_CONN_STRING  = "AZURE_DEMO22_COSMOSDB_SQLDB_CONN_STRING";
        public const string AZURE_DEMO22_COSMOSDB_SQLDB_DBNAME       = "AZURE_DEMO22_COSMOSDB_SQLDB_DBNAME";
        public const string AZURE_DEMO22_COSMOSDB_SQLDB_KEY          = "AZURE_DEMO22_COSMOSDB_SQLDB_KEY";
        public const string AZURE_DEMO22_COSMOSDB_SQLDB_URI          = "AZURE_DEMO22_COSMOSDB_SQLDB_URI";
        public const string AZURE_DEMO22_COSMOSDB_SQLDB_PREF_REGIONS = "AZURE_DEMO22_COSMOSDB_SQLDB_PREF_REGIONS";
        public const string AZURE_DEMO22_COSMOSDB_BULK_BATCH_SIZE    = "AZURE_DEMO22_COSMOSDB_BULK_BATCH_SIZE";
        
        // Constants; command-line and keywords:
        public const string CLI_ARGS_STRING                = "CLI_ARGS_STRING";  // for executing in a Docker container
        public const string INFILE_KEYWORD                 = "--infile";
        public const string VERBOSE_FLAG                   = "--verbose";

        // Class variables:
        private static Config singleton;

        // Instance variables:
        private string[] cliArgs = { };

        public static Config Singleton(string[] args) {  // called by Program.cs Main()

            if (singleton == null) {
                singleton = new Config(args);
            }

            return singleton;
        }

        public static Config Singleton() {  // called elsewhere

            return singleton;
        }

        private Config(string[] args) {
            cliArgs = args;  // dotnet run xxx yyy -> args:["xxx","yyy"]
            if (cliArgs.Length == 0) {
                // If no args, then the Program was invoked in a Docker container, 
                // so use the CLI_ARGS_STRING environment variable instead.
                cliArgs = GetEnvVar(CLI_ARGS_STRING, "").Split();
                Console.WriteLine("CLI_ARGS: " + JsonConvert.SerializeObject(cliArgs));
            }
        }

        public bool IsValid() {
            Console.WriteLine("Config#IsValid args: " + JsonConvert.SerializeObject(cliArgs));

            if (cliArgs.Length < 2) {
                Console.WriteLine("ERROR: empty command-line args");
                return false;
            }

            return true;
        }

        public string[] GetCliArgs() {
            return cliArgs;
        }

        public string GetDemoRepoDir() {
            string osNameAndVersion = System.Runtime.InteropServices.RuntimeInformation.OSDescription;
            Console.WriteLine($"osNameAndVersion: {osNameAndVersion}");
            // osNameAndVersion Darwin 20.6.0 Darwin Kernel Version 20.6.0: Wed Jun 23 00:26:31 PDT 2021; root:xnu-7195.141.2~5/RELEASE_X86_64
            // osNameAndVersion: Linux 5.4.0-1055-azure #57~18.04.1-Ubuntu SMP Fri Jul 16 19:40:19 UTC 2021
            
            if (osNameAndVersion.Contains("Darwin")) {
                return GetEnvVar(AZURE_DEMO22_REPO_DIR_MAC, null);  
            }
            else if (osNameAndVersion.Contains("Win")) {
                return GetEnvVar(AZURE_DEMO22_REPO_DIR_WIN, null);
            }
            else {
                return GetEnvVar(AZURE_DEMO22_REPO_DIR_LINUX, null);
            }
        }

        public string GetCosmosConnString() {
            return GetEnvVar(AZURE_DEMO22_COSMOSDB_SQLDB_CONN_STRING, null);
        }

        public string GetCosmosUri() {
            return GetEnvVar(AZURE_DEMO22_COSMOSDB_SQLDB_URI, null);
        }

        public string GetCosmosKey() {
            return GetEnvVar(AZURE_DEMO22_COSMOSDB_SQLDB_KEY, null);
        }

        public string GetCosmosDbName() {
            return GetEnvVar(AZURE_DEMO22_COSMOSDB_SQLDB_DBNAME, null);
        }

        public string[] GetCosmosPreferredRegions() {
            string delimList = GetEnvVar(AZURE_DEMO22_COSMOSDB_SQLDB_PREF_REGIONS, null);
            if (delimList == null) {
                return new string[] { };
            }
            else {
                return delimList.Split(',');
            }
        }

        public string GetEnvVar(string name) {
            return Environment.GetEnvironmentVariable(name);
        }

        public string GetEnvVar(string name, string defaultValue = null) {
            string value = Environment.GetEnvironmentVariable(name);
            if (value == null) {
                return defaultValue;
            }
            else {
                return value;
            }
        }

        public string GetCliKeywordArg(string keyword, string defaultValue = null) {
            try {
                for (int i = 0; i < cliArgs.Length; i++) {
                    if (keyword == cliArgs[i]) {
                        return cliArgs[i + 1];
                    }
                }
                return defaultValue;
            }
            catch {
                return defaultValue;
            }
        }

        public bool HasCliFlagArg(string flag) {
            for (int i = 0; i < cliArgs.Length; i++) {
                if (cliArgs[i].Equals(flag)) {
                    return true;
                }
            }
            return false;
        }

        public int BulkBatchSize() {
            string val = GetEnvVar(AZURE_DEMO22_COSMOSDB_BULK_BATCH_SIZE, null);
            int defaultValue = 100;
            if (val == null) {
                return defaultValue;
            }
            else {
                try {
                    return Int32.Parse(val);
                }
                catch {
                    return defaultValue;
                }
            }
        }

        public bool IsVerbose() {
            for (int i = 0; i < cliArgs.Length; i++) {
                if (cliArgs[i] == VERBOSE_FLAG) {
                    return true;
                }
            }

            return false;
        }

        public void Display() {
            Console.WriteLine("Config:");
            Console.WriteLine($"  args:            {JsonConvert.SerializeObject(GetCliArgs())}");
        }
    }
}
