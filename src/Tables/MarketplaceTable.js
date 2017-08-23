import React, { Component } from "react";
import RaisedButton from "material-ui/RaisedButton";
import { TableRow, TableRowColumn } from "material-ui/Table";
import { tableRowStyle, tableColumnStyle } from "./TableStyles"
import BaseTable from "./BaseTable";

class MarketplaceTable extends Component {
  render() {
    return (
      <BaseTable
        headers={["DIN", "Name", "Market", "Buy"]}
        rows={this.props.products.map(product => {
          return (
            <TableRow style={tableRowStyle} key={product.DIN}>
              <TableRowColumn>
                {product.DIN}
              </TableRowColumn>
              <TableRowColumn style={tableColumnStyle}>
                {product.name}
              </TableRowColumn>
              <TableRowColumn>
                {product.market}
              </TableRowColumn>
              <TableRowColumn>
                <RaisedButton
                  label="Buy"
                  backgroundColor="#32C1FF"
                  labelColor="#FFFFFF"
                  onClick={() => this.props.handleBuy(product)}
                />
              </TableRowColumn>
            </TableRow>
          );
        })}
      />
    );
  }
}

export default MarketplaceTable;