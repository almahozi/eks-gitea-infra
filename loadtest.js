import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 200,
  duration: '3m',
};

export default function () {
  http.get('http://k8s-default-gitea-278ff7d493-1549881267.eu-central-1.elb.amazonaws.com');
  sleep(0.1);
}