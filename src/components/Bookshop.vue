<template>
  <div>

    <!--<div>-->
      <!--<Account :contract="pcontract"></Account>-->
    <!--</div>-->

    <!--<br/>-->
    <!--<br/>-->

    <!--&lt;!&ndash;setpublickey&ndash;&gt;-->
    <!--<div>-->
      <!--<Input v-model="value" placeholder="Regist your public key ..." style="width: 300px"></Input>-->
      <!--<Button @click="setPublickey()">Register Public Key</Button>-->
    <!--</div>-->


    <!--<br/>-->
    <!--<br/>-->

    <!--&lt;!&ndash;get account&ndash;&gt;-->
    <!--<div>-->
      <!--<Button @click="getFakeFund()">Air Drop</Button>-->
      <!--<Button @click="getBalance()">Refresh account balance</Button>-->
      <!--<div>My account banlance is {{balance}}</div>-->
    <!--</div>-->

    <br/>
    <br/>
    <br/>



    <!--Mybooks-->


    <br/>
    <br/>

    <!--Make order-->


    <br/>
    <br/>







    <!--system message-->
    <br/>
    <br/>
    <div class="message" v-if="message">{{message}}</div>
  </div>
</template>

<script>/* eslint-disable */
// import needs
import Web3 from "web3";
import contract from "truffle-contract";
import artifacts from "../../build/contracts/Bookshop.json";
import Buffer from 'buffer'

const BookshopContract = contract(artifacts);
const buffer = Buffer;

import IPFS from "ipfs-api"
// const IPFS = require('ipfs-api');
const ipfs = new IPFS({host: 'ipfs.infura.io', port: 5001, protocol: 'https'});



import Account from './Key'


export default {
  name: "Bookshop",
  components: {Account},

  data() {
    return {
      pcontract: null,
      balance: null,
      message: null,
      contractAddress: null,
      value: "",
      publicKey: "",
      i: null,


      // upload files
      file: null,
      loadingStatus: false,
      fileBuffer: null,
      ipfsHash: null,

      myBooks: [],
      allBooks: [],


      // make order


      // my orders



    };
  },

  created() {
    console.info('bookshop created')
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
      BookshopContract.deployed()
        .then(instance => {
          this.i = instance;
          return instance.address;
        })
        .then(address => {
          this.contractAddress = address;
        });
    });



    this.getBooks();

    this.getBalance();

    this.getUserSellOrders();
    this.getUserBuyOrders();
    console.info('bookshop created end')
  },

  methods: {


























    // Make order


    updateKey(key) {
      console.log(key)
    }


  }
}
</script>


<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  h1,
  h2 {
    font-weight: normal;
  }

  ul {
    list-style-type: none;
    padding: 0;
  }

  li {
    display: inline-block;
    margin: 0 10px;
  }

  a {
    color: #42b983;
  }
</style>
