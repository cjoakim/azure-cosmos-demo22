// This class implements logic to format a GPS location in GeoJSON format,
// such as the following.  See http://geojson.org
//
//   "location": {
//     "type": "Point",
//     "coordinates": [
//       -86.8138056,
//       39.6335556
//     ]
//   }
//
// Chris Joakim, Microsoft, August 2021

namespace CosmosConsole22 {

    using System;
    using Newtonsoft.Json;

    public class Location
    {
        public string type { get; set; }
        public double[] coordinates { get; set; }

        public Location(double lat, double lng)
        {
            this.type = "Point";
            this.coordinates =  new double[2];
            this.coordinates[0] = lng;
            this.coordinates[1] = lat;
        }
        
        public Location(String lat, String lng)
        {
            this.type = "Point";
            this.coordinates =  new double[2];
            try {
                this.coordinates[0] = Double.Parse(lat);
                this.coordinates[1] = Double.Parse(lng);
            }
            catch {
                this.coordinates[0] = -0.0;
                this.coordinates[1] = -0.0;
            }
        }

        public override string ToString()
        {
            return $"[{coordinates[0]},{coordinates[1]}]";
        }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
