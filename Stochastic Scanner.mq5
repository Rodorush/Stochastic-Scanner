//+------------------------------------------------------------------+
//|                                           Stochastic Scanner.mq5 |
//|                                       Rodolfo Pereira de Andrade |
//|                                     https://rodorush.com.br/blog |
//+------------------------------------------------------------------+
#property copyright "Rodolfo Pereira de Andrade"
#property link      "https://rodorush.com.br/blog"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Script program vela function                                     |
//+------------------------------------------------------------------+

double buyPrice;
int total, vela;
long chart_id;
string symbol;

void OnStart() {
   ENUM_TIMEFRAMES period = ChartPeriod(0);

   double high[], stoch[], signal[];
   int stochHandle;
   int buys = 0;
   
   if(!GlobalVariableCheck("vela")) GlobalVariableSet("vela",1);
   vela = (int)GlobalVariableGet("vela");
   ArraySetAsSeries(stoch,true);
   ArraySetAsSeries(signal,true);
   ArraySetAsSeries(high,true);

   
   total = SymbolsTotal(true);
   for(int i=0;i<total;i++) {                                                    //Percorre todos os símbolos disponíveis no terminal.
      symbol = SymbolName(i,true);
      
      stochHandle = iStochastic(symbol,period,14,3,3,MODE_SMA,STO_LOWHIGH);
      CopyBuffer(stochHandle,0,0,3,stoch);
      CopyBuffer(stochHandle,1,0,3,signal);
      
      if(stoch[vela+1] < signal[vela+1] && stoch[vela] > signal[vela]) {
         buys++;
         CopyHigh(symbol,period,0,3,high);
         buyPrice = high[vela]+SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
         if(IsChartOpened(i)) continue;
         Print("("+IntegerToString(i+1)+"/"+IntegerToString(total)+") "+symbol+" = BUY em "+DoubleToString(buyPrice,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)));
         chart_id = ChartOpen(symbol,period);
         if(chart_id == 0) {
            MessageBox("Não foi possível abrir o gráfico de "+symbol,"Erro ao abrir um gráfico!");
            continue;
         }
         ChartApplyTemplate(chart_id,"3EMA-5-10-20 STOCH14-3-3 SAR.tpl");
         DesenhaLinha();
      }else if(stoch[vela] < signal[vela]) {
         Print("("+IntegerToString(i+1)+"/"+IntegerToString(total)+") "+symbol+" = RADAR");
      }else Print("("+IntegerToString(i+1)+"/"+IntegerToString(total)+") "+symbol+" = OUT");
   }
   Print("Total de BUYs = "+IntegerToString(buys));
}

bool IsChartOpened(int pos) {
   long currChart = ChartFirst();
   long prevChart = currChart;
   int i=0,limit=200; 
   //Print("ChartFirst =",ChartSymbol(prevChart)," ID =",prevChart); 
   while(i<limit)// Temos certamente não mais do que 200 gráficos abertos 
     { 
      if(ChartSymbol(currChart) == symbol) {
         Print("("+IntegerToString(pos+1)+"/"+IntegerToString(total)+") "+symbol+" = BUY em "+DoubleToString(buyPrice,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))+". Mas já está aberto.");
         DesenhaLinha();
         return(true);
      }
      currChart=ChartNext(prevChart); // Obter o ID do novo gráfico usando o ID gráfico anterior 
      if(currChart<0) break;          // Ter atingido o fim da lista de gráfico 
      //Print(i,ChartSymbol(currChart)," ID =",currChart); 
      prevChart=currChart;// vamos salvar o ID do gráfico atual para o ChartNext() 
      i++;// Não esqueça de aumentar o contador 
     }
   return(false);
}

void DesenhaLinha() {
bool falhou = true;
   do {
      if(ObjectCreate(chart_id,"Compra",OBJ_HLINE,0,0,buyPrice))
       if(ObjectFind(chart_id,"Compra") == 0)
        if(ObjectSetInteger(chart_id,"Compra",OBJPROP_STYLE,STYLE_DASH))
         if(ObjectGetInteger(chart_id,"Compra",OBJPROP_STYLE) == STYLE_DASH)
          if(ObjectSetInteger(chart_id,"Compra",OBJPROP_COLOR,clrAqua))
           if(ObjectGetInteger(chart_id,"Compra",OBJPROP_COLOR) == clrAqua) {
              ChartRedraw(chart_id);
              falhou = false;
           }
   }while(falhou && !IsStopped());
}
//+------------------------------------------------------------------+