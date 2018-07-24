import Vue from 'vue'
import Router from 'vue-router'
import Layout from '@/components/Layout'
// import Key from '@/components/Key'
// import Account from '@/components/Account'
// import Publish from '@/components/Publish'
// import Books from '@/components/Books'
// import MakeOrder from '@/components/MakeOrder'
// import Orders from '@/components/Orders'
// import Download from '@/components/Download'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Layout',
      component: Layout
    },
    // {
    //   path: '/key',
    //   name: 'Key',
    //   component: Key
    // },
    // {
    //   path: '/account',
    //   name: 'Account',
    //   component: Account
    // },
    // {
    //   path: '/publish',
    //   name: 'Publish',
    //   component: Publish
    // },
    // {
    //   path: '/books',
    //   name: 'Books',
    //   component: Books
    // },
    // {
    //   path: '/makeorder',
    //   name: 'MakeOrder',
    //   component: MakeOrder
    // },
    // {
    //   path: '/orders',
    //   name: 'Orders',
    //   component: Orders
    // },
    // {
    //   path: '/download',
    //   name: 'Download',
    //   component: Download
    // }

  ]
})
