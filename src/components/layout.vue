<template>
  <Tabs value="name1">

    <TabPane label="Set Key" name="name1">
      <Key :contract="pcontract" :account="paccount"></Key>
    </TabPane>
    <TabPane label="Account" name="name2">
      <Account :contract="pcontract" :account="paccount"></Account>
    </TabPane>
    <TabPane label="Publish Book" name="name3">
      <Publish :contract="pcontract" :account="paccount"></Publish>
    </TabPane>
    <TabPane label="Book List" name="name4">
      <Books :contract="pcontract" :account="paccount"></Books>
    </TabPane>
    <TabPane label="Make Order" name="name5">
      <MakeOrder :contract="pcontract" :account="paccount"></MakeOrder>
    </TabPane>
    <TabPane label="Orders" name="name6">
      <Orders :contract="pcontract" :account="paccount"></Orders>
    </TabPane>
    <TabPane label="Download" name="name7">
      <Download :contract="pcontract" :account="paccount"></Download>
    </TabPane>
  </Tabs>
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
    data(){
      return {
        pcontract : null,
        paccount : null,
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
          this.message =
            "There was an error fetching your accounts. Do you have Metamask, Mist installed or an Ethereum node running? If not, you might want to look into that";
          return;
        }
        if (accs.length === 0) {
          this.message =
            "Couldn't get any accounts! Make sure your Ethereum client is configured correctly.";
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

  }
</script>
