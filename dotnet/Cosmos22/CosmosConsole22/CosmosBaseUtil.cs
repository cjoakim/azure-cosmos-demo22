// Chris Joakim, Microsoft, August 2021

namespace CosmosConsole22 {
    
    using System;
    using System.Threading.Tasks;
    using System.Collections.Generic;
    using Microsoft.Azure.Cosmos;
    using Microsoft.Azure.Cosmos.Core;
    using Newtonsoft.Json;
    
    public abstract class CosmosBaseUtil {
        
        protected CosmosClient client = null;
        protected bool         verbose = false;
        protected Database     currentDatabase = null;
        protected Container    currentContainer = null;
        
        protected CosmosBaseUtil() {
            
        }
        
        public async Task<Database> SetCurrentDatabase(string name) {
            try {
                this.currentDatabase = client.GetDatabase(name);
                return await currentDatabase.ReadAsync();
            }
            catch (Exception e) {
                Console.WriteLine($"SetCurrentDatabase {name} -> Exception {e}");
                return null;
            }
        }
        
        public async Task<Container> SetCurrentContainer(string name) {
            try {
                this.currentContainer = this.currentDatabase.GetContainer(name);
                return await currentContainer.ReadContainerAsync();
            }
            catch (Exception e) {
                Console.WriteLine($"SetCurrentContainer {name} -> Exception {e}");
                return null;
            }  
        }
    }
}