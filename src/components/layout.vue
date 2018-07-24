<template>
  <div>

  <Menu mode="horizontal" theme="light" style="margin-bottom: 20px" active-name="key" @on-select="onSelect">
    <MenuItem name="key">
      <Icon type="ios-gear"></Icon>
      Set Key
    </MenuItem>

    <MenuItem name="account">
      <Icon type="person"></Icon>
      Account
    </MenuItem>

    <MenuItem name="publish">
      <Icon type="ios-book"></Icon>
      Publish Book
    </MenuItem>

    <MenuItem name="books">
      <Icon type="ios-list"></Icon>
      Book List
    </MenuItem>

    <MenuItem name="makeorder">
      <Icon type="hammer"></Icon>
      Make Order
    </MenuItem>

    <MenuItem name="orders">
      <Icon type="checkmark"></Icon>
      Orders
    </MenuItem>

    <MenuItem name="download">
      <Icon type="ios-download"></Icon>
      Download
    </MenuItem>

  </Menu>
    <div id="container">
      <Key v-if="show=='key'" :contract="pcontract" :account="paccount"></Key>
      <Account v-if="show=='account'" :contract="pcontract" :account="paccount"></Account>
      <Publish v-if="show=='publish'" :contract="pcontract" :account="paccount"></Publish>
      <Books v-if="show=='books'" :contract="pcontract" :account="paccount"></Books>
      <MakeOrder v-if="show=='makeorder'" :contract="pcontract" :account="paccount"></MakeOrder>
      <Orders v-if="show=='orders'" :contract="pcontract" :account="paccount"></Orders>
      <Download v-if="show=='download'" :contract="pcontract" :account="paccount"></Download>
    </div>

  <!--<Tabs value="keyTab" @on-click="clickKey">-->

    <!--<TabPane label="Set Key" name="keyTab">-->
      <!--<Key v-if="showKey" :contract="pcontract" :account="paccount"></Key>-->
    <!--</TabPane>-->
    <!--<TabPane label="Account" name="accountTab">-->
      <!--<Account v-if="showAccount" :contract="pcontract" :account="paccount"></Account>-->
    <!--</TabPane>-->
    <!--<TabPane label="Publish Book" name="publishTab">-->
      <!--<Publish v-if="showPublish" :contract="pcontract" :account="paccount"></Publish>-->
    <!--</TabPane>-->
    <!--<TabPane label="Book List" name="booksTab">-->
      <!--<Books v-if="showBooks" :contract="pcontract" :account="paccount"></Books>-->
    <!--</TabPane>-->
    <!--<TabPane label="Make Order" name="makeOrderTab">-->
      <!--<MakeOrder v-if="showMakeOrder" :contract="pcontract" :account="paccount"></MakeOrder>-->
    <!--</TabPane>-->
    <!--<TabPane label="Orders" name="ordersTab">-->
      <!--<Orders v-if="showOrders" :contract="pcontract" :account="paccount"></Orders>-->
    <!--</TabPane>-->
    <!--<TabPane label="Download" name="downloadTab">-->
      <!--<Download v-if="showDownload" :contract="pcontract" :account="paccount"></Download>-->
    <!--</TabPane>-->
  <!--</Tabs>-->
  </div>
</template>

<script>/* eslint-disable */
import Web3 from "web3";
import contract from "truffle-contract";
import artifacts from "../../build/contracts/Bookshop.json";
import Key from './Key'
import Account from './Account'
import Publish from './Publish'
import Books from './Books'
import MakeOrder from './MakeOrder'
import Orders from './Orders'
import Download from './Download'

const BookshopContract = contract(artifacts);

export default {
  name: "layout",
  components: {Key, Account, Publish, Books, MakeOrder, Orders, Download},
  data() {
    return {
      pcontract: null,
      paccount: null,
      show:'key',
      // showKey: true,
      // showAccount: false,
      // showPublish: false,
      // showBooks: false,
      // showMakeOrder: false,
      // showOrders: false,
      // showDownload: false,
    }
  },
  created() {
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
    this.pcontract = BookshopContract
    web3.eth.getAccounts((err, accs) => {
      if (err != null) {
        console.error(err);
        console.log("There was an error fetching your accounts. Do you have Metamask, Mist installed or an Ethereum node running? If not, you might want to look into that");
        return;
      }
      if (accs.length === 0) {
        console.log("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }
      this.account = accs[0];
      this.paccount = accs[0];
      BookshopContract.deployed()
        .then(instance => {
          this.i = instance;
          return instance.address;
        })
        .then(address => {
          this.contractAddress = address;
        });
    });


  },

  methods: {
    onSelect (val) {
      // this.$router.push(`/${val}`)
      this.show = val;

    }
  },

}
</script>

<style scoped>
  #container {
    margin-left: 20px;

  }
</style>
