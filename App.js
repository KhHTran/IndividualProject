import React from 'react';
import ColourButton from './component/ColourButton.js';
import {FormControl} from 'react-bootstrap';

export default class App extends React.Component {
	constructor(props) {
		super(props);
		this.state = {deskused:[2,4,3,3,3]};
		this.handleClick = this.handleClick.bind(this);
	}

	handleClick(e) {
		e.preventDefault();
		var value;
		var day = parseInt(e.target.attributes.y.nodeValue);
		switch(e.target.className) {
			case "Home btn btn-default":
				e.target.className = "Office btn btn-default";
				e.target.style["background-color"] = 'green';
				value = 1;
				e.target.textContent = "Office";
				break;
			case "Office btn btn-default":
				e.target.className = "Off btn btn-default";
				e.target.style["background-color"] = 'blue';
				value = -1;
				e.target.textContent = "Off";
				break;
			default :
				e.target.className = "Home btn btn-default";
				e.target.style["background-color"] = 'red';
				value = 0;
				e.target.textContent = "Home";
				break;
		}
		var temp = this.state.deskused;
		temp[day] += value;
		this.setState({deskused : temp});
	}

	mouseOver(e) {
		e.preventDefault();
		switch(e.target.className) {
			case "Office btn btn-default":
				e.target.style["background-color"] = "green";
				break;
			case "Home btn btn-default":
				e.target.style["background-color"] = "red";
				break;
			default:
				e.target.style["background-color"] = "blue";
				break;
		}
	}

	render() {
		return(
			<div>
				{"----------" + this.state.deskused[0] + "--------------------" + 
				this.state.deskused[1] + "--------------------" + 
				this.state.deskused[2] + "--------------------" + 
				this.state.deskused[3] + "--------------------" + this.state.deskused[4]}
				<div>
					<ColourButton className = 'Home' x = "0" y = "0" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "0" y = "1" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "0" y = "2" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "0" y = "3" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Home' x = "0" y = "4" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
				</div>
				<div>
					<ColourButton className = 'Home' x = "1" y = "0" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "1" y = "1" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Home' x = "1" y = "2" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "1" y = "3" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "1" y = "4" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
				</div>
				<div>
					<ColourButton className = 'Home' x = "2" y = "0" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "2" y = "1" onClick = {this.handleClick}onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "2" y = "2" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Home' x = "2" y = "3" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "2" y = "4" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
				</div>
				<div>
					<ColourButton className = 'Office' x = "3" y = "0" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "3" y = "1" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Home' x = "3" y = "2" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "3" y = "3" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Home' x = "3" y = "4" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
				</div>
				<div>
					<ColourButton className = 'Office' x = "4" y = "0" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Home' x = "4" y = "1" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "4" y = "2" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Home' x = "4" y = "3" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
					<ColourButton className = 'Office' x = "4" y = "4" onClick = {this.handleClick} onMouseOver={this.mouseOver}/>
				</div>
			</div>
		);
	}
}