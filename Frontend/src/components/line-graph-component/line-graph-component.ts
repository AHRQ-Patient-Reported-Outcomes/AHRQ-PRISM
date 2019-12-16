import { Component, Input, ViewChild } from '@angular/core';

import * as _ from 'lodash';
import { Chart } from 'chart.js';

@Component({
  selector: 'line-graph-component',
  templateUrl: 'line-graph-component.html'
})
export class LineGraphComponent {
  @Input() chartData: any;
  @Input() chartColor: any;
  @Input() horizontalAxisLines: boolean;
  @Input() chartHeight: number;
  @Input() displayYGridlines: boolean;
  @Input() displayAxis: boolean;

  @ViewChild('lineCanvas') lineCanvas;

  lineChart: any;
  userHistory: any;
  monthData: any;
  testData: any;

  constructor() { }

  ngAfterViewInit() {
    this.createGraph();
  }

  chartColors() {
    console.log(this.chartColor)
    if (this.chartColor === 'pink') {
      return {
        groundColor: "rgba(220,30,220,1)",
        borderColor: "rgba(220,30,220,1)",
        pointBorderColor: "rgba(220,30,220,1)",
        shadowColor: '#F4F'
      }
    } else {
      return {
        groundColor: "rgb(179, 179, 179)",
        borderColor: "rgb(179, 179, 179)",
        pointBorderColor: "rgb(179, 179, 179)",
        shadowColor: "#B0B0B0"
      }
    }
  }

  createGraph(){

    const chartColors = this.chartColors();

    let draw = Chart.controllers.line.prototype.draw;
    Chart.controllers.line = Chart.controllers.line.extend({
      draw: function() {
        draw.apply(this, arguments);
        let ctx = this.chart.chart.ctx;
        let _stroke = ctx.stroke;
        ctx.stroke = function() {
          ctx.save();
          ctx.shadowColor = chartColors['shadowColor'];
          ctx.shadowBlur = 15;
          ctx.shadowOffsetX = 0;
          ctx.shadowOffsetY = 15;
          _stroke.apply(this, arguments)
          ctx.restore();
        }
      }
    });

    const finalData = _.orderBy(this.chartData, ['date'], ['asc']).map((obj) => {
      return { x: obj['date'], y: obj['score'] }
    });

    const { highestScore, lowestScore } = finalData.reduce((accumulator, currentValue) => {
      if (currentValue.y > accumulator.highestScore) {
        accumulator.highestScore = currentValue.y;
      } else if (currentValue.y < accumulator.lowestScore) {
        accumulator.lowestScore = currentValue.y;
      }

      return accumulator;
    }, {highestScore: 0, lowestScore: 100});

    const config = {
      type: 'line',
      data: {
        datasets: [{
          label: "Score",
          fill: false,
          backgroundColor: chartColors['backgroundColor'],
          borderColor: chartColors['borderColor'],
          pointBorderColor: chartColors['pointBorderColor'],
          data: finalData
        }]
      },
      options: {
        maintainAspectRatio: false,
        legend: { display: false },
        elements: { point: { radius: 0 } },
        scales: {
          yAxes: [{
            gridLines: { display: this.horizontalAxisLines },
            display: this.horizontalAxisLines,
            ticks: {
              max: highestScore + 5,
              min: lowestScore - 5,
              callback: function(value, index, values) {
                if (value % 10 !== 0) {
                  return null;
                }

                return value
              }
            }
          }],
          xAxes: [{
            type: 'time',
            time: {
              unit: 'day',
              displayFormats: {
                day: "D/MM",
                week: "D/MM",
                month: 'MMM'
              }
            },
            ticks: {
              source: 'auto'
            },
            gridLines: { display: false },
            display: this.horizontalAxisLines,
            scaleLabel: { display: true }
          }]
        },
      }
    }

    const ctx = this.lineCanvas.nativeElement;
    ctx.height = this.chartHeight;
    this.lineChart = new Chart(ctx, config);
  }
}
