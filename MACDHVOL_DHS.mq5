//+------------------------------------------------------------------+
//|                                                 MACDHVOL_DHS.mq5 |
//|                                                               DH |
//|                                       https://a1h3.wordpress.com |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
#property copyright "DH"
#property link      "https://a1h3.wordpress.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot MediaMovil
#property indicator_label1  "MACDVOL"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Silver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "LINEA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input int      periodoRapido=12;
input int      periodoLento=26;
input int      periodoSenal=9;
input ENUM_APPLIED_VOLUME VolumenUtilizado=VOLUME_REAL; // Applied price
//--- indicator buffers
double         MACDBuffer[];
double         EMALentoDatoBuffer[];
double         EMALentoResultadoBuffer[];
double         EMARapidoDatoBuffer[];
double         EMARapidoResultadoBuffer[];
double         SENALBuffer[];
double         HistogramaBuffer[];
double         LineaBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HistogramaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LineaBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,MACDBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,EMALentoDatoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,EMALentoResultadoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,EMARapidoDatoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,EMARapidoResultadoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,SENALBuffer,INDICATOR_CALCULATIONS);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,periodoLento-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,periodoLento-1);
//--- name for Dindicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD_VOL_Histograma_DHS("+string(periodoRapido)+","+string(periodoLento)+
                      ","+string(periodoSenal)+")");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Cálculo de Media Móvil
   
   if(rates_total<periodoLento-1) return(0);
   
   int inicio,bar;
      
   if(prev_calculated==0)
   {
      EMALentoDatoBuffer[0]=0.0;
      EMALentoResultadoBuffer[0]=0.0;
      EMARapidoDatoBuffer[0]=0.0;
      EMARapidoResultadoBuffer[0]=0.0;
   }
   
   if(prev_calculated==0) inicio=1;
   else inicio=prev_calculated-1;
   
   if(VolumenUtilizado==VOLUME_REAL){
      for(bar=inicio;bar<rates_total;bar++)
      {
         EMALentoDatoBuffer[bar]=(double)volume[bar]/1000000.0;
         EMARapidoDatoBuffer[bar]=(double)volume[bar]/1000000.0;
      }
   } else {
      for(bar=inicio;bar<rates_total;bar++)
      {
         EMALentoDatoBuffer[bar]=(double)tick_volume[bar];
         EMARapidoDatoBuffer[bar]=(double)tick_volume[bar];
      }
   }
   ExponentialMAOnBuffer(rates_total,prev_calculated,1,periodoLento,EMALentoDatoBuffer,EMALentoResultadoBuffer);
   ExponentialMAOnBuffer(rates_total,prev_calculated,1,periodoRapido,EMARapidoDatoBuffer,EMARapidoResultadoBuffer);
   
   for(bar=inicio;bar<rates_total;bar++)
   {
      MACDBuffer[bar]=EMARapidoResultadoBuffer[bar]-EMALentoResultadoBuffer[bar];
   }
   ExponentialMAOnBuffer(rates_total,prev_calculated,1,periodoSenal,MACDBuffer,SENALBuffer);
   
   for(bar=inicio;bar<rates_total;bar++)
   {
      HistogramaBuffer[bar]=MACDBuffer[bar]-SENALBuffer[bar];
      LineaBuffer[bar]=MACDBuffer[bar]-SENALBuffer[bar];
      
   }
    
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
