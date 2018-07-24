<template>
  <div>
    <Form ref="formOrder" :model="formOrder" :label-width="80">

      <FormItem label="Publisher Address" prop="address">
        <Input type="text" v-model="formOrder.address"></Input>
      </FormItem>
      <FormItem label="Book Price" prop="price">
        <Input type="text" v-model="formOrder.price"></Input>
      </FormItem>
      <FormItem label="Book Index" prop="index">
        <Input type="text" v-model="formOrder.index"></Input>
      </FormItem>

      <FormItem>
        <div style="margin-bottom: 10px">
          <Icon v-show="showDown" type="ios-checkmark" size="20"></Icon>
          <Icon v-show="showFail" type="ios-close" size="20"></Icon>
        </div>
        <Button type="primary" @click="handleOrderSubmit('formOrder')">Submit</Button>
        <Button type="ghost" @click="handleOrderReset('formOrder')" style="margin-left: 8px">Reset</Button>
      </FormItem>
    </Form>

  </div>
</template>

<script>/* eslint-disable */
export default {
  name: "MakeOrder",
  props: [
    "contract",
    "account"
  ],
  data() {
    return {
      formOrder: {
        address: null,
        price: null,
        index: null,
      },
      showDown: false,
      showFail: false,
    }
  },
  created () {
    console.log("Initial MakeOrder");
  },
  methods: {

    handleOrderSubmit(name) {
      this.showDown = false;
      this.showFail = false;
      this.makeOrder(this.account, this.formOrder.address,
        this.formOrder.price, this.formOrder.index)
    },

    handleOrderReset(name) {
      this.$refs[name].resetFields();

      this.showDown = false;
      this.showFail = false;
    },

    makeOrder(buyer, seller, price, bookIndex) {
      this.contract.deployed().then(i => {
        i.makeOrder(buyer, seller, price, bookIndex, {from: this.account})
          .then(res => {
            console.log(res);
            this.showDown = true;
          }).catch(e => {
          console.error(e.message);
          this.showFail = true;
        });
      })
    },


  }

}
</script>

<style scoped>

</style>
