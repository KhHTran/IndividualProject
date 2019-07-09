import React from 'react';
import Button from 'react-bootstrap';
import './ColourButton.css';

export default ({className,...props}) =>
	<Button className = {className} {...props}>
		{className}
	</Button>;