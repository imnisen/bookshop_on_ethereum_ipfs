/* eslint-disable */
// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'

// use iview ui
import iView from 'iview'
import 'iview/dist/styles/iview.css'
Vue.use(iView)

// use web3
import Web3 from "web3";
import contract from "truffle-contract";
import artifacts from "../build/contracts/Bookshop.json";

const BookshopContract = contract(artifacts);

if (typeof web3 !== "undefined") {
  console.warn(
    "Using web3 detected from external source. If you find that your accounts don't appear or you have 0 Fluyd, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask"
  );
  // Use Mist/MetaMask's provider
  web3 = new Web3(web3.currentProvider);
} else {
  console.warn(
    "No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask"
  );
  // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
  web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));
}

BookshopContract.setProvider(web3.currentProvider);


Vue.prototype.contract = BookshopContract;
Vue.prototype.w3 = web3;

Vue.config.productionTip = false

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>'
})
