//+------------------------------------------------------------------+
//|                                           Stochastic Scanner.mq5 |
//|                                       Rodolfo Pereira de Andrade |
//|                                     https://rodorush.com.br/blog |
//+------------------------------------------------------------------+
#property copyright "Rodolfo Pereira de Andrade"
#property link      "https://rodorush.com.br/blog"
#property version   "1.01"

double buyPrice;
int symbolsTotal, candle;
long chart_id;
string symbolName;
string templateName = "3EMA-5-10-20 STOCH14-3-3 SAR.tpl";

void OnStart() {
   ENUM_TIMEFRAMES period = ChartPeriod(0);

   double high[], stoch[], signal[];
   int stochHandle;
   int buys = 0;
   
   if(!GlobalVariableCheck("candle")) GlobalVariableSet("candle",1);
   candle = (int)GlobalVariableGet("candle");
   ArraySetAsSeries(stoch,true);
   ArraySetAsSeries(signal,true);
   ArraySetAsSeries(high,true);

   symbolsTotal = SymbolsTotal(true);
   for(int i=0;i<symbolsTotal;i++) {                                                    //Percorre todos os símbolos disponíveis no terminal.
      symbolName = SymbolName(i,true);
      
      stochHandle = iStochastic(symbolName,period,14,3,3,MODE_SMA,STO_LOWHIGH);
      CopyBuffer(stochHandle,0,0,3,stoch);
      CopyBuffer(stochHandle,1,0,3,signal);
      
      if(stoch[candle+1] < signal[candle+1] && stoch[candle] > signal[candle]) {
         buys++;
         CopyHigh(symbolName,period,0,3,high);
         buyPrice = high[candle]+SymbolInfoDouble(symbolName,SYMBOL_TRADE_TICK_SIZE);
         if(IsChartOpened(i)) continue;
         Print("("+IntegerToString(i+1)+"/"+IntegerToString(symbolsTotal)+") "+symbolName+" = BUY em "+DoubleToString(buyPrice,(int)SymbolInfoInteger(symbolName,SYMBOL_DIGITS)));
         chart_id = ChartOpen(symbolName,period);
         if(chart_id == 0) {
            MessageBox("Não foi possível abrir o gráfico de "+symbolName,"Erro ao abrir um gráfico!");
            continue;
         }
         CheckTemplateAndApply();
         DesenhaLinha();
      }else if(stoch[candle] < signal[candle]) {
         Print("("+IntegerToString(i+1)+"/"+IntegerToString(symbolsTotal)+") "+symbolName+" = RADAR");
      }else Print("("+IntegerToString(i+1)+"/"+IntegerToString(symbolsTotal)+") "+symbolName+" = OUT");
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
      if(ChartSymbol(currChart) == symbolName) {
         Print("("+IntegerToString(pos+1)+"/"+IntegerToString(symbolsTotal)+") "+symbolName+" = BUY em "+DoubleToString(buyPrice,(int)SymbolInfoInteger(symbolName,SYMBOL_DIGITS))+". Mas já está aberto.");
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

void CheckTemplateAndApply() {
   if(FileIsExist(templateName)) { 
      if(ChartApplyTemplate(chart_id,templateName)) { 
         ChartRedraw(chart_id); 
      }else {
         Print("Falha ao aplicar " + templateName + ", código de erro ",GetLastError()); 
      }
   }else {
      Print("Arquivo " + templateName + " não encontrado em " + TerminalInfoString(TERMINAL_PATH)+"\\MQL5\\Files");
   }
}
//+------------------------------------------------------------------+