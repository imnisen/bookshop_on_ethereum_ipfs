<template>

  <!--get public key-->
  <div>
    <Form :model="formKey" :label-width="80">

      <FormItem label="My Public Key">
        <Input v-model="formKey.publicKey" style="width: 300px" readonly type="textarea" autosize></Input>
        <Button @click="getPublickey()">Refresh Public Key</Button>
      </FormItem>
      <FormItem label="Set Public Key">
        <Input v-model="formKey.value" placeholder="Place your Public Key..." style="width: 300px" type="textarea" autosize></Input>
        <Button @click="setPublickey()">Set Public Key</Button>
      </FormItem>

      <FormItem label="Key Pair Generator">
        <Button @click="generateKeyPair()">Generate Key Pair</Button>
        <p>
          Public Key:
        </p>
        <Input v-model="formKey.newPublicKey"  style="width: 300px" type="textarea" autosize></Input>
        <p>
          Private Key（Keep safe）:
        </p>
        <Input v-model="formKey.newPrivateKey" style="width: 300px" type="textarea" autosize></Input>
      </FormItem>

    </Form>





  </div>


</template>
<script>/* eslint-disable */

// import {cryptico} from '../cryptico/cryptico.js'
import forge from 'node-forge'

export default {

  name: "Key",
  // 从bookShop传入的值
  props: [
    "contract",
    "account"
  ],
  data() {
    return {
      formKey: {
        newPublicKey: null,
        newPrivateKey: null,
        publicKey: null,
        value:null,
        passPhrase: null
      },

    }
  },
  created() {
    console.log("Initial Key");
    this.getPublickey();
  },
  methods: {
    // /**
    //  * 子组件触发父组件updateKey方法并传值
    //  */
    // updatePublicKey() {
    //   this.$emit('updateKey', this.publicKey)
    // }

    getPublickey() {
      this.contract.deployed().then(i => {
        i.getPublickey({from: this.account})
          .then(res => {
            console.log(res);
            this.formKey.publicKey = res;
          }).catch(e => {
          console.error(e.message);
        });
      })
    },

    setPublickey() {
      this.contract.deployed().then(i => {
        i.setPublickey(this.formKey.value, {from: this.account})
          .then(res => {
            console.log(res);

            // setTimeout(() => {
            //   this.getPublickey()
            // }, 5000);

          }).catch(e => {
          console.error(e.message);
        });
      })

    },

    generateKeyPair() {

      var rsa = forge.pki.rsa;
      var pki = forge.pki;

      var keypair = rsa.generateKeyPair({bits: 1024, e: 0x10001});

      this.formKey.newPrivateKey = pki.privateKeyToPem(keypair.privateKey)
      this.formKey.newPublicKey = pki.publicKeyToPem(keypair.publicKey)





    }


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
