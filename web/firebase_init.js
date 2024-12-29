import { initializeApp } from "https://www.gstatic.com/firebasejs/11.1.0/firebase-app.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/11.1.0/firebase-analytics.js";

const firebaseConfig = {
  apiKey: "AIzaSyB6YJTbkxnhlAGRHkdrfhcxuDx40i1p8kc",
  authDomain: "waste-management-ebd7b.firebaseapp.com",
  projectId: "waste-management-ebd7b",
  storageBucket: "waste-management-ebd7b.firebasestorage.app",
  messagingSenderId: "948890268716",
  appId: "1:948890268716:web:9f56aa00468ec008744d89",
  measurementId: "G-EN6Y4QV7JX"
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
