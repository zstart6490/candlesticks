import 'package:candlesticks/src/models/indicator.dart';
import 'dart:math' as math;
import 'candle.dart';
import 'package:flutter/material.dart';

class IndicatorComponentData {
  final String name;
  final Color color;
  final List<double?> values = [];
  final Indicator parentIndicator;
  IndicatorComponentData(this.parentIndicator, this.name, this.color);
  bool visible = true;
}

class MainWidnowDataContainer {
  List<IndicatorComponentData> indicatorComponentData = [];
  List<Indicator> indicators;
  List<double> highs = [];
  List<double> lows = [];
  List<String> unvisibleIndicators = [];
  late DateTime beginDate;
  late DateTime endDate;

  void toggleIndicatorVisibility(String indicatorName) {
    if (unvisibleIndicators.contains(indicatorName)) {
      unvisibleIndicators.remove(indicatorName);
      indicatorComponentData.forEach((element) {
        if (element.parentIndicator.name == indicatorName) {
          element.visible = true;
        }
      });
    } else {
      unvisibleIndicators.add(indicatorName);
      indicatorComponentData.forEach((element) {
        if (element.parentIndicator.name == indicatorName) {
          element.visible = false;
        }
      });
    }
  }

  MainWidnowDataContainer(this.indicators, List<Candle> candles) {
    endDate = candles[0].date;
    beginDate = candles.last.date;
    indicators.forEach((indicator) {
      indicator.indicatorComponentsStyles.forEach((indicatorComponent) {
        indicatorComponentData.add(IndicatorComponentData(
            indicator, indicatorComponent.name, indicatorComponent.color));
      });
    });

    candles.forEach((candle) {
      highs.add(candle.high);
      lows.add(candle.low);
    });

    indicators.forEach((indicator) {
      final List<IndicatorComponentData> containers = indicatorComponentData
          .where((element) => element.parentIndicator == indicator)
          .toList();

      for (int i = 0; i < candles.length; i++) {
        double low = lows[i];
        double high = highs[i];

        List<double?> indicatorDatas = List.generate(
            indicator.indicatorComponentsStyles.length, (index) => null);

        if (i + indicator.dependsOnNPrevCandles < candles.length) {
          indicatorDatas = indicator.calculator(i, candles);
        }

        for (int i = 0; i < indicatorDatas.length; i++) {
          containers[i].values.add(indicatorDatas[i]);
          if (indicatorDatas[i] != null) {
            low = math.min(low, indicatorDatas[i]!);
            high = math.max(high, indicatorDatas[i]!);
          }
        }
        lows[i] = low;
        highs[i] = high;
      }
    });
  }

  void tickUpdate(List<Candle> candles) {
    // update last candles
    for (int i = 0; candles[i].date.compareTo(endDate) > 0; i++) {
      highs.insert(i, candles[i].high);
      lows.insert(i, candles[i].low);
      indicatorComponentData.forEach((element) {
        element.values.insert(i, null);
      });
    }
    indicators.forEach(
      (indicator) {
        final List<IndicatorComponentData> containers = indicatorComponentData
            .where((element) => element.parentIndicator == indicator)
            .toList();

        for (int i = 0; candles[i].date.compareTo(endDate) >= 0; i++) {
          double low = lows[i];
          double high = highs[i];

          List<double?> indicatorDatas = List.generate(
              indicator.indicatorComponentsStyles.length, (index) => null);

          if (i + indicator.dependsOnNPrevCandles < candles.length) {
            indicatorDatas = indicator.calculator(i, candles);
          }

          for (int j = 0; j < indicatorDatas.length; j++) {
            containers[j].values[i] = indicatorDatas[j];
            if (indicatorDatas[j] != null) {
              low = math.min(low, indicatorDatas[j]!);
              high = math.max(high, indicatorDatas[j]!);
            }
          }
          lows[i] = low;
          highs[i] = high;
        }
      },
    );
    endDate = candles[0].date;

    // update prev candles
    int firstCandleIndex = 0;
    for (int i = candles.length; i >= 0; i++) {
      if (candles[i].date == beginDate) {
        firstCandleIndex = i;
      }
    }
    for (int i = firstCandleIndex + 1; i < candles.length; i++) {
      highs.add(candles[i].high);
      lows.add(candles[i].low);
      indicatorComponentData.forEach((element) {
        element.values.add(null);
      });
    }
    indicators.forEach(
      (indicator) {
        final List<IndicatorComponentData> containers = indicatorComponentData
            .where((element) => element.parentIndicator == indicator)
            .toList();

        // TODO
        for (int i = 0; candles[i].date.compareTo(endDate) >= 0; i++) {
          double low = lows[i];
          double high = highs[i];

          List<double?> indicatorDatas = List.generate(
              indicator.indicatorComponentsStyles.length, (index) => null);

          if (i + indicator.dependsOnNPrevCandles < candles.length) {
            indicatorDatas = indicator.calculator(i, candles);
          }

          for (int j = 0; j < indicatorDatas.length; j++) {
            containers[j].values[i] = indicatorDatas[j];
            if (indicatorDatas[j] != null) {
              low = math.min(low, indicatorDatas[j]!);
              high = math.max(high, indicatorDatas[j]!);
            }
          }
          lows[i] = low;
          highs[i] = high;
        }
      },
    );
    endDate = candles[0].date;
  }
}
