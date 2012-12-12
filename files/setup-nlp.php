<?php

// become the admin user
$GLOBALS['user'] = user_load(1);

function _nlp_role() {
  $rid = array_search('nlp', user_roles());
  if (!empty($rid)) {
    return $rid;
  }

  require_once(drupal_get_path('module', 'user') . "/user.admin.inc");

  $form_id = "user_admin_new_role";
  $form_values = array();
  $form_values["name"] = "nlp";
  $form_values["op"] = t('Add role');
  $form_state = array();
  $form_state["values"] = $form_values;

  drupal_execute($form_id, $form_state);

  $rid = array_search('nlp', user_roles());

  db_query("INSERT INTO {permission} (rid, perm) VALUES (%d, '%s')", $rid, "administer nodes");

  return $rid;
}

function _nlp_user() {
  $password = user_password(8);

  $uid = db_result(db_query("SELECT uid FROM {users} WHERE name = 'NLP'"));
  if (!empty($uid)) {
    db_query("UPDATE {users} SET pass = MD5('%s') WHERE uid = %d", $password, $uid);
    return array('NLP', $password);
  }

  require_once(drupal_get_path('module', 'user') . "/user.admin.inc");

  $form_state = array();
  $form_state['values']['name'] = 'NLP';
  $form_state['values']['mail'] = $form_state['values']['conf_mail'] = 'nlp@example.com';
  $form_state['values']['pass']['pass1'] = $password;
  $form_state['values']['pass']['pass2'] = $password;
  $form_state['values']['op'] = t('Create new account');

  try {
    drupal_execute('user_register', $form_state);
  }
  catch (Exception $e) {
    print $e->getMessage();
  }

  $uid = db_result(db_query("SELECT uid FROM {users} WHERE name = 'NLP'"));
  $rid = _nlp_role();

  db_query("INSERT INTO {users_roles} (uid, rid) VALUES (%d, %d)", $uid, $rid);

  return array('NLP', $password);
}

function _nlp_key() {
  $key = db_result(db_query("SELECT kid FROM {services_keys} WHERE domain = 'nlp'"));
  if (!empty($key)) {
    return array('nlp', $key);
  }

  require_once(drupal_get_path('module', 'services_keyauth') . "/services_keyauth.admin.inc");

  $form_state = array();
  $form_state['values']['title'] = 'NLP';
  $form_state['values']['domain'] = 'nlp';
  $form_state['values']['method_access'] = array(
    'node.get'            => 'node.get',
    'node.save'           => 'node.save',
    'system.connect'      => 'system.connect',
    'user.login'          => 'user.login',
    'user.logout'         => 'user.logout',
    'lingwo_entry.search' => 'lingwo_entry.search',
  );
  $form_state['values']['op'] = t('Create key');
  drupal_execute('services_keyauth_admin_keys_form', $form_state);

  $key = db_result(db_query("SELECT kid FROM {services_keys} WHERE domain = 'nlp'"));
  return array('nlp', $key);
}

function _nlp_site() {
  if (preg_match('/sites\/(.*)%/', conf_path(), $matches)) {
    return $matches[1];
  }
}

function _nlp_write_config($path) {
  $site = _nlp_site();
  list ($domain, $key) = _nlp_key();
  list ($user, $password) = _nlp_user();

  $lines = array();
  $lines[] = "DOMAIN = '$domain'";
  $lines[] = "KEY = '$key'";
  $lines[] = "USERNAME = '$user'";
  $lines[] = "PASSWORD = '$password'";
  $lines[] = "URL = 'http://$site/services/xmlrpc'";

  file_put_contents($path, implode("\n", $lines));
}

_nlp_write_config("/var/aegir/prj/lingwo-old/nlp/LingwoNLP/config.py");

