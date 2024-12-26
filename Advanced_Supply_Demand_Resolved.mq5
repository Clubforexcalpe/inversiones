// Advanced Supply Demand Indicator for MetaTrader 5

#property indicator_chart_window
#property strict

//--- Input parameters for Supply Demand zones
input int MinCandles = 5;            // Minimum candles before a zone is printed
input double MinPriceMoveX = 2.0;   // Minimum Factor X price displacement (ATR)
input double MinPriceMoveY = 1.5;   // Minimum Factor Y price displacement (Zone Size)
input double MaxZoneSize = 3.0;     // Maximum Zone Size (ATR)

//--- Input parameters for Multi-Timeframe (MTF) analysis
input bool AddHigherTF = true;       // Add higher timeframe zones
input ENUM_TIMEFRAMES HigherTF = PERIOD_H4;  // Higher timeframe period
input int MinCandlesHTF = 3;         // Min candles for higher timeframe zone
input double MinPriceMoveXHTF = 2.5; // Minimum Factor X price displacement (ATR) for HTF
input double MinPriceMoveYHTF = 2.0; // Minimum Factor Y price displacement (Zone Size) for HTF
input double MaxZoneSizeHTF = 4.0;   // Maximum Zone Size (ATR) for HTF
input bool ShowInternalLabels = true;   // Show internal price labels
input bool ShowExternalLabels = true;   // Show external price labels
input bool ShowOldZones = true;         // Show old zones

//--- Alert settings
input bool AlertOnEnter = true;        // Alert when price enters the zone
input bool AlertOnBreak = true;        // Alert when price breaks the zone
input bool AlertOnReversalCandle = true; // Alert on reversal candle formation
input bool EnableEmailAlert = false;   // Enable email alert
input bool EnablePushAlert = false;    // Enable push notification

//--- Global variables
struct Zone {
   datetime start;
   double high;
   double low;
   color zone_color;
};

Zone DemandZones[];
Zone SupplyZones[];

//--- Function to calculate ATR
double CalculateATR(int period) {
   return iATR(_Symbol, _Period, period);
}

//--- Function to draw zone
void DrawZone(Zone &zone, string name) {
   if (ObjectCreate(0, name, OBJ_RECTANGLE, 0, zone.start, zone.low)) {
      ObjectSetInteger(0, name, OBJPROP_COLOR, zone.zone_color);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetDouble(0, name, OBJPROP_TOP, zone.high);
      ObjectSetDouble(0, name, OBJPROP_BOTTOM, zone.low);
   }
}

//--- Function to identify zones
void IdentifyZones() {
   double atr = CalculateATR(14);
   if (atr == 0) return; // Prevent division by zero

   for (int i = MinCandles; i < Bars; i++) {
      double range = iHigh(_Symbol, _Period, i) - iLow(_Symbol, _Period, i);
      if (range > atr * MinPriceMoveX) {
         Zone zone;
         zone.start = iTime(_Symbol, _Period, i);
         zone.high = iHigh(_Symbol, _Period, i);
         zone.low = iLow(_Symbol, _Period, i);
         zone.zone_color = clrGreen;
         ArrayResize(DemandZones, ArraySize(DemandZones) + 1);
         DemandZones[ArraySize(DemandZones) - 1] = zone;
         DrawZone(zone, "DemandZone" + IntegerToString(i));
      } else if (range < -atr * MinPriceMoveX) {
         Zone zone;
         zone.start = iTime(_Symbol, _Period, i);
         zone.high = iHigh(_Symbol, _Period, i);
         zone.low = iLow(_Symbol, _Period, i);
         zone.zone_color = clrRed;
         ArrayResize(SupplyZones, ArraySize(SupplyZones) + 1);
         SupplyZones[ArraySize(SupplyZones) - 1] = zone;
         DrawZone(zone, "SupplyZone" + IntegerToString(i));
      }
   }
}

//--- OnInit function
int OnInit() {
   // Validate initialization of objects and variables
   if (Bars < MinCandles) {
      Print("Error: Not enough bars for initialization");
      return(INIT_FAILED);
   }

   IdentifyZones();
   return(INIT_SUCCEEDED);
}

//--- OnCalculate function
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                 const double &open[], const double &high[], const double &low[], const double &close[],
                 const long &tick_volume[], const long &volume[], const int &spread[]) {
   return(rates_total);
}
