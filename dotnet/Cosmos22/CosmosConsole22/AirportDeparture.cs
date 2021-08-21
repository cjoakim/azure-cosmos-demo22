// Chris Joakim, Microsoft, August 2021

namespace CosmosConsole22 {

    using System;
    using Newtonsoft.Json;

    public class AirportDeparture
    {
        public string id { get; set; }

        public string pk { get; set; }

        public string date { get; set; }

        public string year { get; set; }

        public string month { get; set; }

        public string from_iata { get; set; }

        public string to_iata { get; set; }

        public string airlineid { get; set; }

        public string carrier { get; set; }

        public string count { get; set; }

        public string route { get; set; }

        public string from_airport_name { get; set; }

        public string from_airport_tz { get; set; }

        public string from_airport_lat { get; set; }

        public string from_airport_lng { get; set; }

        public string to_airport_name { get; set; }

        public string to_airport_country { get; set; }

        public string to_airport_tz { get; set; }

        public string to_airport_lat { get; set; }

        public string to_airport_lng { get; set; }
        
        public Location from_location { get; set; }
        public Location to_location { get; set; }
        
        public AirportDeparture(string delimLine)
        {

        }

        public void PostParse()
        {
            pk = route;
            this.from_location = new Location(this.from_airport_lat, this.from_airport_lng);
            this.to_location   = new Location(this.to_airport_lat, this.to_airport_lng);
            if (this.id == null)
            {
                this.id = Guid.NewGuid().ToString();
            }
        }

        public bool IsValid()
        {
            try {
                // if (Math.Abs(AirportId) < 1) {
                //     return false;
                // }
                // if (String.IsNullOrEmpty(Name)) {
                //     return false;
                // }
                // if (String.IsNullOrEmpty(City)) {
                //     return false;
                // }
                // if (String.IsNullOrEmpty(Country)) {
                //     return false;
                // }
                // if (String.IsNullOrEmpty(IataCode)) {
                //     return false;
                // }
                // if (String.IsNullOrEmpty(TimezoneCode)) {
                //     return false;
                // }
                // if (Math.Abs(Latitude) < 0.00001) {
                //     return false;
                // }
                // if (Math.Abs(Longitude) < 0.00001) {
                //     return false;
                // }
                // if ((Altitude < -600) || (Altitude > 10000)) {
                //     return false;
                // }
            }
            catch (Exception e) {
                Exception baseException = e.GetBaseException();
                Console.WriteLine("Error in IsValid: {0}, Message: {1}", e.Message, baseException.Message);
                return false;
            }
            return true;
        }

        public override string ToString()
        {
            bool valid = IsValid();
            //return $"{AirportId}:{IataCode}:{Name}:{City}:{Country}:{Latitude}:{Longitude}:{TimezoneCode}:{TimezoneNum}:{valid}";
            return this.ToJson();
        }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
