const express = require('express');
const router = express.Router();
const pg = require('pg');
const path = require('path');
const connectionString = 'postgres://postgres:1234@localhost:5432/room_booking';

// Home Page Service
router.get('/', function (req, res, next) {
  res.render('index', { title: 'Express' });
});


// Login Service
router.post('/api/login', (req, res, next) => {
  const results = [];
  // Grab data from http request
  const data = { username: req.body.username, password: req.body.password };
  //basic validations
  if (!req.body.username) {
    return res.send({ "status": "error", "message": "username is missing" });
  } else if (!req.body.password) {
    return res.send({ "status": "error", "message": "password is missing" });
  } else {
    // Get a Postgres client from the connection pool
    pg.connect(connectionString, (err, client, done) => {
      // Handle connection errors
      if (err) {
        done();
        console.log(err);
        return res.status(500).json({ success: false, data: err });
      }
      // SQL Query > Insert Data
      const query = client.query('SELECT * FROM check_user_login($1,$2)', [data.username, data.password]);
      // Stream results back one row at a time
      query.on('row', (row) => {
        results.push(row);
      });
      // After all data is returned, close connection and return results
      query.on('end', () => {
        done();
        return res.json(results);
      });
    });
  }
});


// User Creation Service
router.post('/api/usercreation', (req, res, next) => {
  const results = [];
  // Grab data from http request
  const data = { username: req.body.empId, emailId: req.body.emailId, password: req.body.password };
  //basic validations
  if (!data.username) {
    return res.send({ "status": "error", "message": "Employee Id is missing" });
  } else if (!data.password) {
    return res.send({ "status": "error", "message": "Password is missing" });
  } else if (!data.emailId) {
    return res.send({ "status": "error", "message": "Email Id is missing" });
  } else {
    // Get a Postgres client from the connection pool
    pg.connect(connectionString, (err, client, done) => {
      // Handle connection errors
      if (err) {
        done();
        console.log(err);
        return res.status(500).json({ success: false, data: err });
      }
      // SQL Query > Insert Data
      const query = client.query('SELECT * FROM create_user($1,$2,$3)', [data.username, data.password, data.emailId]);
      // Stream results back one row at a time
      query.on('row', (row) => {
        results.push(row);
      });
      // After all data is returned, close connection and return results
      query.on('end', () => {
        done();
        return res.json(results);
      });
    });
  }
});


// Get Booking History Service
router.post('/api/bookinghistory', (req, res, next) => {
  const results = [];
  // Grab data from http request
  const id = req.body.userId;
  //basic validations
  if (!id) {
    return res.send({ "status": "error", "message": "User Id is missing" });
  } else {
    // Get a Postgres client from the connection pool
    pg.connect(connectionString, (err, client, done) => {
      // Handle connection errors
      if (err) {
        done();
        console.log(err);
        return res.status(500).json({ success: false, data: err });
      }
      // SQL Query > Insert Data
      const query = client.query('SELECT * FROM get_booking_history($1)', [id]);
      // Stream results back one row at a time
      query.on('row', (row) => {
        results.push(row);
      });
      // After all data is returned, close connection and return results
      query.on('end', () => {
        done();
        return res.json(results);
      });
    });
  }
});


module.exports = router;