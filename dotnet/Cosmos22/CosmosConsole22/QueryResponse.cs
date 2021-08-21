using System.ComponentModel;
using System.Net;
using Microsoft.Azure.Cosmos;

namespace CosmosConsole22 {
    
    using System;
    using System.Collections.Generic;
    using Newtonsoft.Json;
    
    public class QueryResponse {
        
        public string queryName { get; set; }
        public string date { get; set; }
        public string dbname { get; set; }
        
        public string cname { get; set; }
        public string sql { get; set; }
        public HttpStatusCode statusCode { get; set; }
        public List<dynamic> items { get; set; }
        public int itemCount { get; set; }
        public double totalRequestCharge { get; set; }
        
        public double elapsedMs { get; set; }
        public Exception exception { get; set; }
        
        public string filename { get; set; }
        
        public QueryResponse() {
            date = DateTime.Now.ToString("s");
            items = new List<dynamic>();
            totalRequestCharge = 0.0;
            exception = null;
        }

        public void IncrementRequestCharge(double incrementalRU) {
            totalRequestCharge = totalRequestCharge + incrementalRU;
        }

        public void AddItem(dynamic item) {
            items.Add(item);
            itemCount = items.Count;
        }

        public int ItemCount() {
            return items.Count;
        }

        public bool HasException() {
            return exception != null;
        }

        public void Finish() {
            filename = $"out/{queryName}_{dbname}_{cname}.json";
        }

        public override string ToString() {
            return $"QueryResponse: {queryName} {dbname} {cname} {statusCode} {totalRequestCharge} {ItemCount()} {elapsedMs} {HasException()}";
        }
        public string ToJson(bool pretty=true)
        {
            if (pretty) {
                return JsonConvert.SerializeObject(this, Formatting.Indented);
            }
            else {
                return JsonConvert.SerializeObject(this); 
            }
        }
    }
}