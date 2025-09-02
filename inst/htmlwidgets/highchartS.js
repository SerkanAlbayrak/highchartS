HTMLWidgets.widget({

  name: 'highchartS',
  type: 'output',

  factory: function(el, width, height) {
    let chart = null;

    return {
      renderValue: function(x) {

        const opts = {
          title: { text: x.title || '' },
          rangeSelector: { enabled: !!x.rangeSelector },
          navigator: { enabled: true },
          scrollbar: { enabled: true },
          tooltip: { split: true, valueDecimals: 2 },
          yAxis: x.yAxis || [{ title: { text: 'Value' } }],
          series: x.series || []
        };

        chart = Highcharts.stockChart(el, opts);
      },

      resize: function(width, height) {
        if (chart) chart.setSize(width, height, false);
      }
    };
  }
});
