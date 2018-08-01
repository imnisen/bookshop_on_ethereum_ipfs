<template>

  <div>
    <Form ref="formPublish" :model="formPublish" :label-width="100">

      <FormItem label="Which Book" prop="upload">
        <Upload
          :before-upload="handleUpload"
          action="//jsonplaceholder.typicode.com/posts/">
          <Button type="ghost" icon="ios-cloud-upload-outline">To Publish</Button>
        </Upload>
        <div v-if="file !== null">Upload file: {{ file.name }}</div>
      </FormItem>
      <FormItem label="Book Name" prop="name">
        <Input type="text" v-model="formPublish.name"></Input>
      </FormItem>
      <FormItem label="Book Price" prop="price">
        <Input type="text" v-model="formPublish.price"></Input>
      </FormItem>

      <FormItem>
        <div style="margin-bottom: 10px">
          <Spin v-show="showPin"></Spin>
          <Icon v-show="showDown" type="ios-checkmark" size="20"></Icon>
          <Icon v-show="showFail" type="ios-close" size="20"></Icon>
        </div>
        <Button type="primary" @click="handleSubmit('formPublish')">Publish</Button>
        <Button type="ghost" @click="handleReset('formPublish')" style="margin-left: 8px">Reset</Button>
      </FormItem>
    </Form>
  </div>

</template>

<script>/* eslint-disable */

import Buffer from 'buffer'
import IPFS from "ipfs-api"

const buffer = Buffer;

const ipfs = new IPFS({host: 'ipfs.infura.io', port: 5001, protocol: 'https'});

import forge from 'node-forge'

export default {
  name: "Publish",
  data() {
    return {
      file: null,
      formPublish: {
        name: '',
        price: '',
      },
      loadingStatus: false,
      fileBuffer: null,
      ipfsHash: null,
      publicKey: null,
      showPin: false,
      showDown: false,
      showFail: false,
    }
  },
  created() {
    this.account = sessionStorage.getItem("account");
    this.getPublickey()
  },
  methods: {
    getPublickey() {
      this.contract.deployed().then(i => {
        i.getPublickey({from: this.account})
          .then(res => {
            console.log(res);
            this.publicKey = res;
            console.log("this.publicKey", this.publicKey)

            if (this.publicKey === "") {
              console.error("Public key is empty")
            }


          }).catch(e => {
          console.error(e.message);
        });
      })
    },

    publishBook(ipfsHash, aesKey, aesIv) {
      console.info('publishBook ipfsHash', ipfsHash);

      this.contract.deployed().then(i => {
        i.publishBook(this.formPublish.name, ipfsHash, this.formPublish.price, aesKey, aesIv, {from: this.account})
          .then(res => {
            console.log(res);
            this.showPin = false;
            this.showDown = true;

            this.$emit('newBookPublished')

          }).catch(e => {
          console.error(e.message);
          this.showPin = false;
          this.showFail = true;
        });
      })
    },

    handleSubmit(name) {
      this.upload(this.publishBook);
    },
    handleReset(name) {
      this.$refs[name].resetFields();
      this.file = null;

      this.showPin = false;
      this.showDown = false;
      this.showFail = false;
    },

    // 上传逻辑
    handleUpload(file) {
      this.file = file;
      console.info(file);
      this.showDown = false;
      this.showFail = false;
      return false;
    },

    // 上传逻辑
    upload(cb) {
      this.showPin = true;
      const _this = this;

      this.loadingStatus = true;

      // transfer to buffer
      const reader = new FileReader();

      reader.onloadend = function () {

        const buf = buffer.Buffer(reader.result); // Convert data into buffer

        var aesKey = forge.random.getBytesSync(16);
        var aesIv = forge.random.getBytesSync(16);
        console.log("---aesKey---", aesKey);
        console.log("---aesKey.length---", aesKey.length);
        console.log("aesIv", aesIv);

        // console.log("_this.publicKey", _this.publicKey);
        var pubKey = forge.pki.publicKeyFromPem(_this.publicKey);


        // buf -> encrypted
        var cipher = forge.cipher.createCipher('AES-CBC', aesKey);
        cipher.start({iv: aesIv});
        cipher.update(forge.util.createBuffer(buf));
        cipher.finish();
        var fileEncrypted = cipher.output;

        // aesKey -> encrypted
        var aesKeyEncrypted = pubKey.encrypt(aesKey);
        console.log("aesKeyEncrypted----", aesKeyEncrypted)

        // transfer file encrypted fromat so that can be upload
        var nodeBuffer = buffer.Buffer(fileEncrypted.getBytes(), 'binary');

        // Upload to ipfs
        ipfs.files.add(nodeBuffer, (err, result) => {
          if (err) {
            console.error(err);
            this.showPin = false;
            return
          }

          let url = `https://ipfs.io/ipfs/${result[0].hash}`;
          console.log(`Url --> ${url}`);

          console.log("aesKeyEncrypted", aesKeyEncrypted)
          console.log("----aesKeyEncrypted.length----", aesKeyEncrypted.length)
          console.log("aesIv", aesIv)
          console.log("result[0].hash", result[0].hash)

          cb(result[0].hash, aesKeyEncrypted, aesIv)
        })

      };

      reader.readAsArrayBuffer(this.file);
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

  .demo-spin-col {
    height: 100px;
    position: relative;
    border: 1px solid #eee;
  }
</style>
