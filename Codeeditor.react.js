import React, {Component} from 'react';
import PropTypes from 'prop-types';
//import CodeMirror from '../../../test/CodeMirror.react'
import CodeMirror from 'react-codemirror';
//import {UnControlled as CodeMirror} from 'react-codemirror2'

require('codemirror/lib/codemirror');
import 'codemirror/lib/codemirror.css';
import 'codemirror/theme/midnight.css';
import 'codemirror/theme/material.css';

require('codemirror/mode/xml/xml');
require('codemirror/mode/javascript/javascript');
require('codemirror/mode/q/q');
require('codemirror/mode/python/python');

/**
 * ExampleComponent is an example component.
 * It takes a property, `label`, and
 * displays it.
 * It renders an input with the property `value`
 * which is editable by the user.
 */
export default class Codeeditor extends Component {

    componentWillReceiveProps(nextProps) {
        console.log(nextProps);
        if (nextProps.code) {
            const editor = this.refs.editor.getCodeMirror();
            editor.setValue(nextProps.code);
        }
    }

    render() {
        const {id, label, setProps, code, mode, theme, tabSize, indentUnit} = this.props;

        return (
            <div id={id}>
                <div>
                {label}&nbsp;
                </div>
                <div>

                <CodeMirror
                    ref="editor" 
                    value={code}
                    options={{
                        mode: mode,
                        theme: theme,
                        tabSize: tabSize,
                        indentUnit: indentUnit,
                        lineNumbers: true
                    }}
                    onBeforeChange={(editor, data, newCode) => {
                        setProps({ code: newCode });
                    }}
                    onChange={(editor, data, newCode) => {
                        setProps({ code: newCode });
                    }}
                />
            </div>
            </div>
        );
    }
}

Codeeditor.defaultProps = {};

Codeeditor.propTypes = {
    /**
     * The ID used to identify this component in Dash callbacks.
     */
    id: PropTypes.string,

    /**
     * A label that will be printed when this component is rendered.
     */
    label: PropTypes.string.isRequired,

    /**
     * The value displayed in the code editor.
     */
    code: PropTypes.string,

    /**
     * The language mode in the code editor.
     */
    mode: PropTypes.string,
    
    /**
     * The layout theme in the code editor.
     */
    theme: PropTypes.string,
 
    /**
     * The layout tabSize in the code editor.
     */
    tabSize: PropTypes.number,

    /**
     * The layout indentUnit in the code editor.
     */
    indentUnit: PropTypes.number,
    /**
     * Dash-assigned callback that should be called to report property changes
     * to Dash, to make them available for callbacks.
     */
    setProps: PropTypes.func
};
