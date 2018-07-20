<template>
  <div>
    <Form ref="formOrder" :model="formOrder" :label-width="80">

      <FormItem label="seller address" prop="address">
        <Input type="text" v-model="formOrder.address"></Input>
      </FormItem>
      <FormItem label="Book Price" prop="price">
        <Input type="text" v-model="formOrder.price"></Input>
      </FormItem>
      <FormItem label="Book Index" prop="index">
        <Input type="text" v-model="formOrder.index"></Input>
      </FormItem>

      <FormItem>
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
    }
  },
  methods: {

    handleOrderSubmit(name) {
      this.makeOrder(this.account, this.formOrder.address,
        this.formOrder.price, this.formOrder.index)


    },

    handleOrderReset(name) {
      this.$refs[name].resetFields();
    },

    makeOrder(buyer, seller, price, bookIndex) {
      this.contract.deployed().then(i => {
        i.makeOrder(buyer, seller, price, bookIndex, {from: this.account})
          .then(res => {
            console.log(res);
          }).catch(e => {
          console.error(e.message);
        });
      })
    },


  }

}
</script>

<style scoped>

</style>
