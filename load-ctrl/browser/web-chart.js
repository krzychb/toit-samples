/*
Inspired by demos on https://www.highcharts.com/
*/

'use strict';

var chartT = new Highcharts.Chart({
    chart:{ renderTo : 'chart-temperature' },
    title: { text: 'Temperature Controller' },
    series: [{
      name: 'Temperature',
      yAxis: 1,
      data: [],
      marker: {
        enabled: undefined
      },
    }, {
      name: 'Setpoint',
      yAxis: 1,
      data: [],
      marker: {
        enabled: false
      },
    }, {
      name: 'PID Output',
      yAxis: 2,
      data: [],
      marker: {
        enabled: false
      },
    }],
    plotOptions: {
      line: { animation: false }
    },
    xAxis: { type: 'datetime',
      dateTimeLabelFormats: { second: '%H:%M:%S' }
    },
    yAxis: [{ // Primary yAxis
      labels: {
          format: '{value}°C',
          style: {
              color: Highcharts.getOptions().colors[0]
          }
      },
      title: {
          text: 'Temperature',
          style: {
              color: Highcharts.getOptions().colors[0]
          }
      },
    }, { // Secondary yAxis
      gridLineWidth: 0,
      title: {
          text: 'Setpoint',
          style: {
              color: Highcharts.getOptions().colors[1]
          }
      },
      labels: {
          format: '{value}°C',
          style: {
              color: Highcharts.getOptions().colors[1]
          }
      }
    }, { // Tertiary yAxis
      gridLineWidth: 0,
      title: {
          text: 'PID Output',
          style: {
              color: Highcharts.getOptions().colors[2]
          }
      },
      labels: {
          format: '{value}%',
          style: {
              color: Highcharts.getOptions().colors[2]
          }
      },
      opposite: true
    }]
  });



/**
 * @name addToChart
 * Add space separated parameters to the chart.
 * @param  {value} a line with values separated by space
 */
function addToChart(value) {
    const tokens = value.split(' ');

    const temperatureText = tokens[3]
    document.getElementById('temperature').textContent = temperatureText;
    const temperature = parseFloat(temperatureText);

    const setpointText = tokens[5];
    document.getElementById('setpoint').textContent = setpointText;
    const setpoint = parseFloat(setpointText);

    const pidOutputText = tokens[7];
    document.getElementById('pidOutput').textContent = pidOutputText;
    const pidOutput = parseInt(pidOutputText);

    const timeStamp = (new Date()).getTime()
    if(chartT.series[0].data.length > 100) {
      chartT.series[0].addPoint([timeStamp, temperature], true, true, true);
      chartT.series[1].addPoint([timeStamp, setpoint], true, true, true);
      chartT.series[2].addPoint([timeStamp, pidOutput], true, true, true);
    } else {
      chartT.series[0].addPoint([timeStamp, temperature], true, false, true);
      chartT.series[1].addPoint([timeStamp, setpoint], true, false, true);
      chartT.series[2].addPoint([timeStamp, pidOutput], true, false, true);
    }
}

