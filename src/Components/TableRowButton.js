import React, { Component } from 'react'

class TableRowButton extends Component {

	handleClick() {
		this.props.handleBuy(this.props.index)
	}

	render() {
		return (
			<button onClick={this.handleClick.bind(this)}>{this.props.title}</button>
		)
	}

}

export default TableRowButton