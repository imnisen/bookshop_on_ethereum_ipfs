<template>

  <!--get public key-->
  <div>

    <div>
      <div>我的账户余额： {{balance}}</div>
      <br/>
      <br/>
      <br/>
      <Button @click="getFakeFund()">获得空投</Button>
      <br/>
      <br/>
      <br/>
      <Button @click="getBalance()">刷新账户余额</Button>

    </div>



  </div>


</template>

<script>/* eslint-disable */
export default {
  name: "Account",
  props: [
    "contract",
    "account"
  ],
  data() {
    return {
      balance: null,
    }
  },
  created() {
    this.getBalance();
  },
  methods: {
    getFakeFund () {
      this.contract.deployed().then(i => {
        i.getFakeFund({from: this.account})
          .then(res => {
            console.log(res);
            this.message = "Transaction done"


          }).catch(e => {
          console.error(e.message);
          this.message = "Transaction failed"



        });
      })
    },

    getBalance () {

      this.contract.deployed().then(i => {
        i.getBalance({from: this.account})
          .then(res => {
            console.log(res);
            this.balance = res.toNumber()


          }).catch(e => {
          console.error(e.message);

        });
      })
    },

  }
}
</script>

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
