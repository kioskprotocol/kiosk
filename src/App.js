import React, { Component } from "react";
// import { Route } from "react-router-dom";
import SideMenu from "./components/SideMenu";
import NavBar from "./components/NavBar";
// import TableContainer from "./tables/TableContainer";
import BuyModal from "./components/BuyModal";
import { connect } from "react-redux";
import { initKiosk } from "./redux/actions";

const mapStateToProps = state => ({
  web3: state.web3,
  hasError: state.web3HasError,
  isLoading: state.web3IsLoading,
  selectedMenuItem: state.selectedMenuItem
});

class App extends Component {
  // Initialize Kiosk (web3, accounts, contracts)
  componentDidMount() {
    const { dispatch } = this.props;
    dispatch(initKiosk());
  }

  render() {
    const { web3, isLoading } = this.props;

    const hContainerStyle = {
      display: "flex", // 💪
      flexFlow: "row",
      width: "100%",
      height: "100%"
    };

    const sideMenuStyle = {
      flex: "1",
      minWidth: "220px",
      maxWidth: "220px",
      height: "100vh"
    };

    const rightContainerStyle = {
      display: "flex",
      flex: "2",
      flexFlow: "column",
      height: "100%"
    };

    const theme = {
      red: "#FC575E",
      blue: "#32C1FF",
      gray: "#2C363F",
      lightGray: "#6E7E85",
      white: "#F6F8FF"
    };

    if (web3 !== null) {
      return (
        <div style={hContainerStyle}>
          <div style={sideMenuStyle}>
            <SideMenu />
          </div>
          <div style={rightContainerStyle}>
            <div>
              <NavBar theme={theme} />
            </div>
            <BuyModal theme={theme} isOpen={false}/>
          </div>
        </div>
      );
    } else if (isLoading === true) {
      // Loading & Handle Error
      return <div />;
    }
    return null;
  }
}

export default connect(mapStateToProps)(App);

// <TableContainer />

// <div style={{ padding: "10px 30px" }} />
// <TableContainer />

//   const ERROR = {
//   NOT_CONNECTED: 1,
//   CONTRACTS_NOT_DEPLOYED: 2,
//   NETWORK_NOT_SUPPORTED: 3,
//   LOCKED_ACCOUNT: 4
// };