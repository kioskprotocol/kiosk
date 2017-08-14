import React, { Component } from "react";
import { Navbar, Nav, NavDropdown, MenuItem } from "react-bootstrap";

class NavigationBar extends Component {
  render() {
    return (
      <Navbar>
        <Navbar.Header>
          <Navbar.Brand>
            <a href="/" className="kiosk-logo">
              kiosk
            </a>
          </Navbar.Brand>
          <Navbar.Toggle />
        </Navbar.Header>
        <Navbar.Collapse>
          <Nav pullRight onSelect={this.handleSelect}>
            <NavDropdown
              eventKey="1"
              title={this.props.account.slice(0, 12)}
              id="nav-dropdown"
            >
              <MenuItem href="/products">My Products</MenuItem>
              <MenuItem href="/orders">My Orders</MenuItem>
              <MenuItem>Balance: {this.props.balance}</MenuItem>
            </NavDropdown>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
    );
  }
}

export default NavigationBar;