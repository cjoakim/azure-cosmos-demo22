// Instances of this class represent a generic and minimal document in CosmosDB,
// containing 'id' and 'pk' attributes.
//
// Chris Joakim, Microsoft, August 2021

namespace CosmosConsole22 {
    
    using System;
    using Microsoft.Azure.Cosmos;
    using Newtonsoft.Json;
    
    public class GenericDocument {
        public string id { get; set; }
        public string pk { get; set; }

        public GenericDocument() {
        }
        
        public GenericDocument(string id, string pk) {

            this.id = id;
            this.pk = pk;
        }

        public PartitionKey GetPartitionKey() {
            return new PartitionKey(pk);
        }
        
        public string ToJson() {
            return JsonConvert.SerializeObject(this);
        }
    }
}
