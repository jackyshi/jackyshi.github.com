import React, {Component} from 'react';
import PropTypes from 'prop-types';

/**
 * ExampleComponent is an example component.
 * It takes a property, `label`, and
 * displays it.
 * It renders an input with the property `value`
 * which is editable by the user.
 */

export default class GraphBuilder extends Component {
    constructor(props) {
        super(props)
    }

    handleChange (e) {
        if (["x", "y"].includes(e.target.className) ) {
          let n_traces = this.props.traces;
          n_traces[e.target.dataset.id][e.target.className] = e.target.value;
          this.props.setProps({ traces:n_traces });
          console.log(this.props.traces);
        } else {
          let f = e.target.name;
          let v = e.target.value;
          this.props.setProps({ [f]: v});
          console.log(this.props);
        }
      }
    addTrace (e) {
        let n_traces=[...this.props.traces, {x:"", y:""}];
        this.props.setProps({ traces:n_traces });
        console.log(this.props.traces);
      }
    
    removeTrace (e) {
        let n_traces = this.props.traces
        n_traces.splice(e.target.id, 1);
        this.props.setProps({ traces:n_traces });
        console.log(this.props.traces);
      }
    
    handleSubmit (e) { 
        e.preventDefault();
        console.log(this.props.traces);
    }

    render() {
        const {id, setProps, owner, description, traces} = this.props;
        
        return (
            <div id={id}>
                <form onSubmit={this.handleSubmit.bind(this)} >
                    <label htmlFor="name">Owner</label> 
                    <input type="text" name="owner" id="owner" value={owner} onChange={this.handleChange.bind(this)}/>
                    <label htmlFor="description">Description</label> 
                    <input type="text" name="description" id="description" value={description} onChange={this.handleChange.bind(this)}/>
                    <button onClick={this.addTrace.bind(this)}>Add new trace</button>
                    {
                    this.props.traces.map((val, idx)=> {
                        let xId = `x-${idx}`, yId = `y-${idx}`
                        return (
                        <div key={idx}>
                            <label>{`Trace #${idx + 1}`}</label>
                            <label htmlFor={xId}>X</label>
                            <input
                            type="text"
                            name={xId}
                            data-id={idx}
                            id={xId}
                            value={traces[idx].x || ''} 
                            className="x"
                            onChange={this.handleChange.bind(this)}
                            />
                            <label htmlFor={yId}>Y</label>
                            <input
                            type="text"
                            name={yId}
                            data-id={idx}
                            id={yId}
                            value={traces[idx].y || ''} 
                            className="y"
                            onChange={this.handleChange.bind(this)}
                            />
                            <button id={idx} onClick={this.removeTrace.bind(this)}>remove trace</button>
                        </div>
                        )
                    })
                    }
                    <input type="submit" value="Submit" /> 
                </form>
            </div>
        );
    }
}

GraphBuilder.defaultProps = {};

GraphBuilder.propTypes = {
    /**
     * The ID used to identify this component in Dash callbacks.
     */
    id: PropTypes.string,

    /**
     * the owner.
     */
    owner: PropTypes.string,

    /**
     * The description.
     */
    description: PropTypes.string,

    /**
     * The description.
     */
    traces:PropTypes.array,
    /**
     * Dash-assigned callback that should be called to report property changes
     * to Dash, to make them available for callbacks.
     */
    setProps: PropTypes.func
};
