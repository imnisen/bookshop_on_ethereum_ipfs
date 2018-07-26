<template>
  <div>

    <Menu mode="horizontal" theme="light" style="margin-bottom: 20px" active-name="account" @on-select="onSelect">
      <MenuItem name="account">
        <Icon type="person"></Icon>
        Account
      </MenuItem>

      <MenuItem name="books">
        <Icon type="ios-book"></Icon>
        Books
      </MenuItem>

      <MenuItem name="make-order">
        <Icon type="hammer"></Icon>
        Make Order
      </MenuItem>

      <MenuItem name="orders">
        <Icon type="checkmark"></Icon>
        Orders
      </MenuItem>

      <MenuItem name="download">
        <Icon type="ios-download"></Icon>
        Download
      </MenuItem>

    </Menu>
    <div id="container">
      <router-view></router-view>
    </div>
  </div>
</template>

<script>/* eslint-disable */

export default {
  name: "layout",
  data() {
    return {
    }
  },
  created() {

    // Initial user account address to session
    this.w3.eth.getAccounts((err, accs) => {
      if (err != null) {
        console.error(err);
        console.log("There was an error fetching your accounts. Do you have Metamask, Mist installed or an Ethereum node running? If not, you might want to look into that");
        return;
      }
      if (accs.length === 0) {
        console.log("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      // set account address
      sessionStorage.setItem("account", accs[0]);

    });
  },

  methods: {
    onSelect(val) {
      this.$router.push(`/${val}`)
    }
  },

}
</script>

<style scoped>
  #container {
    margin-left: 20px;

  }
</style>
