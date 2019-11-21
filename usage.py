import codeeditor
import dash
from dash.dependencies import Input, Output, State
import dash_html_components as html
import dash_core_components as dcc
import glob, os

app = dash.Dash(__name__)

os.chdir("test")
qFiles = []

for file in glob.glob("*.q"):
    print(file)
    qFiles.append({'label': file, 'value': file})

os.chdir("..")

app.layout = html.Div([
    dcc.Dropdown(
        options=qFiles,
        id='fileSelect'
    ),

    codeeditor.Codeeditor(
        id='input',
        code='my-code',
        label='my-label',
        mode='q',
        theme='midnight',
        tabSize=2,
        indentUnit=2
    ),
    html.Div(id='output'),
    html.Button('Publish', id='dash-button', n_clicks=0)
])


#@app.callback(Output('output', 'children'), [Input('input', 'value')])
#def display_output(value):
#    return 'You have entered {}'.format(value)
@app.callback(
    Output('input', 'code'),
    [Input('fileSelect', 'value')])
def load_file(value):
    if value:
        q_file = open('test/'+value, "r")
        q_code = q_file.read()
        return q_code

@app.callback(
    Output('output', 'children'),
    [Input('dash-button', 'n_clicks')],
    [State('input', 'code')])
def get_code(n_clicks, code):
    res = []
    if n_clicks > 0:
        res = code
    return res

if __name__ == '__main__':
    app.run_server(debug=False)
