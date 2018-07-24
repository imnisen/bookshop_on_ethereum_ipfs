<template>

  <!--get public key-->
  <div>
    <Form :model="formAccount" :label-width="80">

      <FormItem label="My Balance">
        <Input v-model="formAccount.balance" style="width: 300px" readonly></Input>
        <Button @click="getBalance()">Refresh Account</Button>
        <Button @click="getFakeFund()">Air drop</Button>
      </FormItem>
    </Form>
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
      formAccount: {
        balance: 0
      },
    }
  },
  created() {
    console.log("Initial Account");
    this.getBalance();
  },
  methods: {
    getFakeFund () {
      this.contract.deployed().then(i => {
        i.getFakeFund({from: this.account})
          .then(res => {
            console.log(res);
          }).catch(e => {
          console.error(e.message);
        });
      })
    },

    getBalance () {
      this.contract.deployed().then(i => {
        i.getBalance({from: this.account})
          .then(res => {
            console.log(res);
            this.formAccount.balance = res.toNumber()
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
