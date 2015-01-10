//+------------------------------------------------------------------+
//|                                                 MACDHVOL_DHS.mq5 |
//|                                                               DH |
//|                                      https://nodisponible.com :-)|
//+------------------------------------------------------------------+

#include <MovingAverages.mqh>
#property copyright "DH"
#property link      "https://nodisponible.com"
#property version   "1.00"
#property indicator_separate_window             // indicador en ventana separada
#property indicator_buffers 7                   // número de buffers empleados
#property indicator_plots   2                   // número de gráficos (histograma y línea)
//--- gráfico Histograma MACDH
#property indicator_label1  "MACDVOL"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Silver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- gráfico Línea que cierra el histograma
#property indicator_label2  "LINEA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- parámetros de entrada en el inicio del indicador
input int      periodoRapido=12;                         // período rápido
input int      periodoLento=26;                          // periodo lento
input int      periodoSenal=9;                           // periodo de la señal
input ENUM_APPLIED_VOLUME VolumenUtilizado=VOLUME_REAL;  // volumen elegido (real o tick)
//--- buffers del indicador
double         MACDBuffer[];                 // buffer para el cálculo del MACD
double         EMADatoBuffer[];              // buffer para introducir el volumen para calcular EMAS
double         EMALentoResultadoBuffer[];    // buffer para almacenar la EMA lenta (LP)
double         EMARapidoResultadoBuffer[];   // buffer para almacenar la EMA rápida (CP)
double         SENALBuffer[];                // buffer para almacenar la señal
double         HistogramaBuffer[];           // buffer para almacenar y pintar el histograma
double         LineaBuffer[];                // buffer para pintar la lína (mismo dato que el histograma


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- inicializamos y mapeamos buffers del indicador
   SetIndexBuffer(0,HistogramaBuffer,INDICATOR_DATA);                // los que pintan deber ir los primeros                
   SetIndexBuffer(1,LineaBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,MACDBuffer,INDICATOR_CALCULATIONS);              // los de cálculo a continuación
   SetIndexBuffer(3,EMADatoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,EMALentoResultadoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,EMARapidoResultadoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,SENALBuffer,INDICATOR_CALCULATIONS);
//--- establecemos la primera barra desde la que el índicador va a ser dibujado
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,periodoLento-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,periodoLento-1);
//--- nombre para el indicador en la etiqueta de la subventana
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
//--- Cálculo de Histograma MACD
   
   if(rates_total<periodoLento-1) return(0);    // si no hay suficientes datos, no hacemos nada
   
   int inicio,bar;      // variables inicio (donde empezamos a pintar) y barra (para el recorrido de los bucles)
      
   if(prev_calculated==0)     // si no se ha realizado ningún cálculo previamente, inicializamos los bucles de cálculo
   {
      EMADatoBuffer[0]=0.0;
      EMALentoResultadoBuffer[0]=0.0;
      EMARapidoResultadoBuffer[0]=0.0;
   }
   
   if(prev_calculated==0) inicio=1; // si no se ha realizado ningún cálculo previo, inicio es 1
   else inicio=prev_calculated-1;   // en otro caso, será la variable prev_calculated-1
   
   if(VolumenUtilizado==VOLUME_REAL){        // rellenamos el búffer de datos con volumen según la elección inicial
      for(bar=inicio;bar<rates_total;bar++)
      {
         EMADatoBuffer[bar]=(double)volume[bar]/1000000.0;     //con volumen real
      }
   } else {
      for(bar=inicio;bar<rates_total;bar++)
      {
         EMADatoBuffer[bar]=(double)tick_volume[bar];          // o con volumen de tick
      }
   }
   
   // Cálculo de las dos medias exponenciales utilizando una función de la librería <MovingAverages.mqh>
   ExponentialMAOnBuffer(rates_total,prev_calculated,1,periodoLento,EMADatoBuffer,EMALentoResultadoBuffer);
   ExponentialMAOnBuffer(rates_total,prev_calculated,1,periodoRapido,EMADatoBuffer,EMARapidoResultadoBuffer);
   
   // Rellenamos el buffer del MACD (diferencia entre la EMA rápida y la EMA lenta)
   for(bar=inicio;bar<rates_total;bar++)
   {
      MACDBuffer[bar]=EMARapidoResultadoBuffer[bar]-EMALentoResultadoBuffer[bar];
   }
   
   // Cálculo de la señal como EMA del MACD utilizando una función de la librería <MovingAverages.mqh>
   ExponentialMAOnBuffer(rates_total,prev_calculated,1,periodoSenal,MACDBuffer,SENALBuffer);
   
   // Rellenamos los buffers del histograma y la línea como diferencia del MACD y la señal.
   for(bar=inicio;bar<rates_total;bar++)
   {
      HistogramaBuffer[bar]=MACDBuffer[bar]-SENALBuffer[bar];
      LineaBuffer[bar]=MACDBuffer[bar]-SENALBuffer[bar];
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }

// Fin de la "cosa"
//+------------------------------------------------------------------+
