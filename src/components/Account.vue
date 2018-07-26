<template>


  <div>
    <!--Balance-->
    <div>
      <Form :model="formAccount" :label-width="100" label-position="left">
        <FormItem v-if="!showSetKey" label="My Public Key">
          <Input v-model="formAccount.publicKey" style="width: 300px" readonly type="textarea" autosize></Input>
          <Button @click="getPublickey()">Refresh Public Key</Button>
        </FormItem>

        <FormItem v-if="showSetKey" label="Set Public Key">
          <Input v-model="formAccount.value" placeholder="Place your Public Key..." style="width: 300px" type="textarea" autosize></Input>
          <Button @click="setPublickey()">Set Public Key</Button>
          <Button @click="getPublickey()">Refresh Public Key</Button>
        </FormItem>

        <FormItem v-if="showSetKey" label="Key Pair Generator">
          <Button @click="generateKeyPair()">Generate Key Pair</Button>
          <p>
            Public Key:
          </p>
          <Input v-model="formAccount.newPublicKey"  style="width: 300px" type="textarea" autosize></Input>
          <p>
            Private Key（Keep safe）:
          </p>
          <Input v-model="formAccount.newPrivateKey" style="width: 300px" type="textarea" autosize></Input>
        </FormItem>

        <FormItem v-if="!showSetKey" label="My Balance">
          <Input v-model="formAccount.balance" style="width: 300px" readonly></Input>
          <Button @click="getBalance()">Refresh Account</Button>
          <Button @click="getFakeFund()">Air drop</Button>
        </FormItem>
      </Form>
    </div>
  </div>


</template>

<script>/* eslint-disable */
import forge from 'node-forge'

export default {
  name: "Account",
  props: [
    "contract",
    "account"
  ],
  data() {
    return {
      showSetKey: false,
      formAccount: {
        newPublicKey: null,
        newPrivateKey: null,
        publicKey: null,
        value:null,
        passPhrase: null,
        balance: 0
      },
    }
  },
  created() {
    console.log("Initial Account");
    this.getPublickey();
    this.getBalance();
  },
  methods: {
    getPublickey() {
      this.contract.deployed().then(i => {
        i.getPublickey({from: this.account})
          .then(res => {
            console.log(res);
            this.formAccount.publicKey = res;
            if (res === "") {
              this.showSetKey = true;
            } else {
              this.showSetKey = false;
            }
          }).catch(e => {
          console.error(e.message);
        });
      })
    },

    setPublickey() {
      this.contract.deployed().then(i => {
        i.setPublickey(this.formAccount.value, {from: this.account})
          .then(res => {
            console.log(res);
          }).catch(e => {
          console.error(e.message);
        });
      })

    },

    generateKeyPair() {

      var rsa = forge.pki.rsa;
      var pki = forge.pki;

      var keypair = rsa.generateKeyPair({bits: 1024, e: 0x10001});

      this.formAccount.newPrivateKey = pki.privateKeyToPem(keypair.privateKey)
      this.formAccount.newPublicKey = pki.publicKeyToPem(keypair.publicKey)

    },

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
