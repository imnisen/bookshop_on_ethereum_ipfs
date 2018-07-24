<template>

  <div>
    <Form ref="formPublish" :model="formPublish" :label-width="80">

      <FormItem label="Upload" prop="upload">
        <Upload
          :before-upload="handleUpload"
          action="//jsonplaceholder.typicode.com/posts/">
          <Button type="ghost" icon="ios-cloud-upload-outline">Which Book</Button>
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
        <Button type="primary" @click="handleSubmit('formPublish')">Submit</Button>
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

// var publicKey;

export default {
  name: "Publish",

  props: [
    "contract",
    "account"
  ],
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
    console.log("Initial Publish");
    // TODO a bug, this will get no public key since first reload, use has no public key
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

      reader.onloadend = function() {

        const buf = buffer.Buffer(reader.result); // Convert data into buffer


        var aesKey = forge.random.getBytesSync(16);
        var aesIv = forge.random.getBytesSync(16);

        console.log("_this.publicKey", _this.publicKey);
        var pubKey = forge.pki.publicKeyFromPem(_this.publicKey);


        // buf -> encrypted
        var cipher = forge.cipher.createCipher('AES-CBC', aesKey);
        cipher.start({iv: aesIv});
        cipher.update(forge.util.createBuffer(buf));
        cipher.finish();
        var fileEncrypted = cipher.output;

        // aesKey -> encrypted
        var aesKeyEncrypted = pubKey.encrypt(aesKey);

        // transfer file encrypted fromat so that can be upload
        var nodeBuffer = buffer.Buffer(fileEncrypted.getBytes(), 'binary');

        // Upload to ipfs
        ipfs.files.add(nodeBuffer, (err, result) => {
          if(err) {
            console.error(err);
            this.showPin = false;
            return
          }

          let url = `https://ipfs.io/ipfs/${result[0].hash}`;
          console.log(`Url --> ${url}`);

          console.log("aesKeyEncrypted", aesKeyEncrypted)
          console.log("aesIv", aesIv)
          console.log("result[0].hash", result[0].hash)

          cb(result[0].hash, aesKeyEncrypted, aesIv)
        })






        // console.info(buf);
        // console.log("this.publicKey2", _this.publicKey)

        // encrypt buffer with public key
        // // encrypt data with a public key (defaults to RSAES PKCS#1 v1.5)
        // var encrypted = publicKey.encrypt(bytes);
        //
        // // decrypt data with a private key (defaults to RSAES PKCS#1 v1.5)
        // var decrypted = privateKey.decrypt(encrypted);
        // this.formKey.newPrivateKey = pki.privateKeyToPem(keypair.privateKey)
        // this.formKey.newPublicKey = pki.publicKeyToPem(keypair.publicKey)

        // var pki = forge.pki;
        // var pub = pki.publicKeyFromPem(_this.publicKey);
        // console.info(pub);
        //
        //
        // // generate aeskey, iv
        //
        // var key = forge.random.getBytesSync(16);
        // var iv = forge.random.getBytesSync(16);
        // console.info('key', key)
        //
        //
        // var cipher = forge.cipher.createCipher('AES-CBC', key);
        // cipher.start({iv: iv});
        // cipher.update(forge.util.createBuffer(buf));
        // cipher.finish();
        // var fileEncrypted = cipher.output;
        // // outputs encrypted hex
        // console.log(fileEncrypted); // this is encrypted file buffer
        //
        //
        // // encrypt aes key
        // var aesKeyEncrypted = pub.encrypt(key);
        //
        // console.log('aesKeyEncrypted', aesKeyEncrypted)
        //
        //
        // // 1. aesKeyEncrypted
        // // 1. iv
        // // 1. fileEncrypted
        // // 1. pub
        //
        //
        //
        // // 1. aesKeyEncrypted
        // // 1. iv
        // // 1. fileEncrypted
        // // 1. priv
        // tmp key :)
        // var p_s = '-----BEGIN RSA PRIVATE KEY-----\n' +
        //   'MIICXAIBAAKBgQCF6lO/FroQXFq7wB165q1nc95XxtVOSRyxhtJPN7xGSVRpO0oa\n' +
        //   'yL9KL1ulbg2dUs6Nsxf53TzDQF+lC4bXusvLlvqsyyJ9fhbzhM4PtTsuJUU7+hXR\n' +
        //   'T7GZckYEMCTvOSQRzZ0fTlABU7GTxGtynj5ElRb11To7Rmi1HYF/ybXepQIDAQAB\n' +
        //   'AoGAMmfNNfP7/QSGMn1Rm10QkAwQ+MEisODcKAYzSxYTi/E2EJX8grBlMCs7N72A\n' +
        //   '6mKs1LFAqRAZOvUUCy+XhcQNyPvcDwRFByeqEbbKqyU0Qbq2LFIWqBuuvvDZ3GHD\n' +
        //   'd15rlenwjNqzyeptYvrVrDe+mqzKPUo3LG3k7eBsJu2ZJgECQQDNaCQgc/Pq2QTS\n' +
        //   'MLDiVIDN2V39ix91dfK8J9dK73QP+wURIVl3zHBNtn8TvFvEZU78KUKaCZzdaqPI\n' +
        //   'fwCL/cChAkEApuZQtMTAfMWJEbaMMmy6YwEG9JUMvOV89IrhboeewgQEqtDM5xH8\n' +
        //   'OVZkGVO7mDBbY6j6NfRmZnzYcpYTiu3rhQJBALCw77q249BWJG6GkfHvTOlGHTL3\n' +
        //   '1PTepBI0l18PgiApBx/IN0T1KHnBDak1cx8LIpmJCJCmyjgw/nh+v0Ks4mECQF5C\n' +
        //   'UzBUsnWFRo13cKSF3ZpOmTQG/eOtJC4kRX8cHyBqDoy+UgrqkG19ihj3vkoMfYDC\n' +
        //   'jVVti2u0dLX6Zl0fU9UCQFfHFl7Q2ppTW+qudRwzji/uGZIkXwtCwZwavEICX25g\n' +
        //   '16s18+NFtl1D/e5wN+l5/ICBLqTVv/ypmxGs9Dp5++4=\n' +
        //   '-----END RSA PRIVATE KEY-----'
        // var priv = pki.privateKeyFromPem(p_s)
        // var aesKeyDecrypted = priv.decrypt(aesKeyEncrypted);
        //
        //
        // var decipher = forge.cipher.createDecipher('AES-CBC', aesKeyDecrypted);
        // decipher.start({iv: iv});
        // decipher.update(fileEncrypted);
        // var result = decipher.finish(); // check 'result' for true/false
        // // outputs decrypted hex
        // console.log(decipher.output.toHex());
        //
        // console.log(forge.util.createBuffer(buf).toHex());
        // console.log(decipher.output.toHex());
        // // 验证通过
        // // console.log('equal?', decipher.output.toHex() == )
        //
        //
        //
        //
        //
        //
        //


        // console.log(encrypted.toHex());


        // var encrypted = pub.encrypt(buf);


        // console.info(encrypted);




        // ipfs.files.add(buf, (err, result) => { // Upload buffer to IPFS
        //   if(err) {
        //     console.error(err)
        //     return
        //   }
        //
        //   let url = `https://ipfs.io/ipfs/${result[0].hash}`;
        //   console.log(`Url --> ${url}`)
        //
        //   cb(result[0].hash)
        // })
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
  .demo-spin-col{
    height: 100px;
    position: relative;
    border: 1px solid #eee;
  }
</style>
