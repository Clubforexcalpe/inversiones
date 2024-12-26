
// Advanced Currency Strength and GAP Indicator for MetaTrader 5

#property indicator_chart_window
#property strict

//--- Input parameters for Currency Strength (CS) and GAP settings
input double MinGAPAngle = 23.0;                  // Minimum GAP angle (MFib 23 equivalent)
input bool EnableFibonacciAlerts = true;         // Enable alerts for Fibonacci levels (161/-161)
input bool DrawDynamicMFibLevels = true;         // Show dynamic historical MFib levels

//--- Alert settings for GAP and Fibonacci levels
input int OuterMFibTriggerLevel = 161;           // Outer MFib trigger level for alerts
input int InnerMFibTriggerLevel = 100;           // Inner MFib trigger level for alerts
input bool AlertOnFibonacciHit = true;           // Alert when hitting Fibonacci levels
input bool AlertOnDirectionChange = true;        // Alert on CS direction change

//--- Graph settings
input bool ShowGAPArrows = true;                 // Show GAP arrows on chart
input int ArrowSize = 2;                         // Size of arrows for GAP
input bool ShowDynamicMFibZones = true;          // Show dynamic MFib zones on chart

//--- Color settings
input color GAPArrowColor = clrOrange;           // Color for GAP arrows
input color MFib161Color = clrMagenta;           // Color for MFib 161 level
input color MFib100Color = clrGreen;             // Color for MFib 100 level
input color MFib0Color = clrGray;                // Color for MFib 0 level

//--- Other settings
input int BarsBack = 500;                        // Number of bars back to calculate
input int AlertDelaySeconds = 5;                 // Delay for alerts in seconds

//--- Global variables
struct CurrencyLine {
   string name;
   color line_color;
   double strength;
   double angle;
};

CurrencyLine Currencies[8];

//--- Initialization function
int OnInit() {
   // Initialize currency lines
   string currency_names[8] = { "EUR", "USD", "GBP", "JPY", "AUD", "CAD", "CHF", "NZD" };
   color currency_colors[8] = { clrWhite, clrRed, clrBlue, clrYellow, clrDeepSkyBlue, clrGreen, clrOrange, clrMagenta };
   
   for (int i = 0; i < 8; i++) {
      Currencies[i].name = currency_names[i];
      Currencies[i].line_color = currency_colors[i];
      Currencies[i].strength = 0.0;
      Currencies[i].angle = 0.0;
   }

   // Validate input parameters
   if (Bars < BarsBack || BarsBack <= 0) {
      Print("Error: Not enough bars for initialization or BarsBack is invalid");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//--- Main calculation function
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                 const double &open[], const double &high[], const double &low[], const double &close[],
                 const long &tick_volume[], const long &volume[], const int &spread[]) {
   for (int i = 0; i < 8; i++) {
      // Update currency strength and angle
      Currencies[i].strength = CalculateCurrencyStrength(Currencies[i].name);
      Currencies[i].angle = CalculateGAPAngle(Currencies[i].strength);
      
      // Draw GAP arrow if conditions are met
      if (ShowGAPArrows && Currencies[i].angle >= MinGAPAngle) {
         DrawGAPArrow(Currencies[i]);
      }
   }

   // Draw MFib levels dynamically if enabled
   if (DrawDynamicMFibLevels) {
      DrawMFibLevels();
   }

   return(rates_total);
}

//--- Calculate currency strength
double CalculateCurrencyStrength(string currency) {
   // Placeholder logic for strength calculation
   return MathRand() % 100; // Replace with actual calculation logic
}

//--- Calculate GAP angle
double CalculateGAPAngle(double strength) {
   // Placeholder for GAP angle calculation
   return MathAbs(strength - 23); // Replace with actual angle calculation
}

//--- Draw GAP arrow
void DrawGAPArrow(CurrencyLine &currency) {
   string arrow_name = currency.name + "_GAPArrow";
   if (ObjectCreate(0, arrow_name, OBJ_ARROW, 0, TimeCurrent(), currency.strength)) {
      ObjectSetInteger(0, arrow_name, OBJPROP_COLOR, GAPArrowColor);
      ObjectSetInteger(0, arrow_name, OBJPROP_WIDTH, ArrowSize);
   }
}

//--- Draw dynamic MFib levels
void DrawMFibLevels() {
   double levels[] = { 0, 23, 100, 161 };
   color colors[] = { MFib0Color, clrOrange, MFib100Color, MFib161Color };

   for (int i = 0; i < ArraySize(levels); i++) {
      string level_name = "MFibLevel_" + IntegerToString(i);
      if (ObjectCreate(0, level_name, OBJ_HLINE, 0, TimeCurrent(), levels[i])) {
         ObjectSetInteger(0, level_name, OBJPROP_COLOR, colors[i]);
      }
   }
}
