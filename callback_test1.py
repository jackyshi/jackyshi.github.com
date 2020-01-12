import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output

import pandas as pd
import plotly.graph_objs as go
import datetime

df = pd.read_csv('tt.csv').head(20)

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

def timestr_toint(time_str):
    return sum(x * int(t) for x, t in zip([3600, 60, 1], time_str.split(":")))

app.layout = html.Div([
    html.Div([
        dcc.RangeSlider(
            id='time-slider',
            min=timestr_toint(df['time'].min()),
            max=timestr_toint(df['time'].max()),
            value=[timestr_toint(df['time'].min()),timestr_toint(df['time'].max())],
            marks={timestr_toint(time): str(time) for time in df['time'].unique()},
            step=None,
            allowCross=False
        )], style={'margin-left': 130, 'margin-right': 100}),
    html.Br(),
    dcc.Graph(id='line-with-slider'),
    dcc.Graph(id='bar-with-slider')
])


@app.callback(
    Output('line-with-slider', 'figure'),
    [Input('time-slider', 'value')])
def update_linefigure(dt_ragne):
    min_dtstr = str(datetime.timedelta(seconds=dt_ragne[0]))
    max_dtstr = str(datetime.timedelta(seconds=dt_ragne[1]))
    filtered_df = df[(df.time >= min_dtstr) & (df.time <= max_dtstr)]
    traces = []
    for i in ['notional','pnl']:
        traces.append(go.Scatter(
            x=filtered_df['time'],
            y=filtered_df[i],
            mode='markers+lines',
            opacity=0.7,
            marker={
                'size': 15,
                'line': {'width': 0.5, 'color': 'white'}
            },
            name=i
        ))

    return {
        'data': traces,
        'layout': go.Layout(
            margin={'l': 40, 'b': 40, 't': 10, 'r': 10},
            legend={'x': 0, 'y': 1},
            hovermode='x'
        )
    }

@app.callback(
    Output('bar-with-slider', 'figure'),
    [Input('time-slider', 'value')])
def update_barfigure(dt_ragne):
    min_dtstr = str(datetime.timedelta(seconds=dt_ragne[0]))
    max_dtstr = str(datetime.timedelta(seconds=dt_ragne[1]))
    filtered_df = df[(df.time >= min_dtstr) & (df.time <= max_dtstr)]
    traces = []
    for i in ['newevt','amendevt','cancelevt']:
        traces.append(go.Bar(
            x=filtered_df['time'],
            y=filtered_df[i],
            opacity=0.7,
            name=i
        ))

    return {
        'data': traces,
        'layout': go.Layout(
            margin={'l': 40, 'b': 40, 't': 10, 'r': 10},
            legend={'x': 0, 'y': 1},
            hovermode='x'
        )
    }

if __name__ == '__main__':
    app.run_server(debug=False)