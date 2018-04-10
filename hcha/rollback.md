# 回滚机制
## 事务回滚
分布式事务对性能影响比较大。

对于互联网应用一般不需要实现强一致性，只要达到最终一致性即可。那么就不需要分布式事务。

可以通过**乐观锁**或者**补偿机制**来处理分布式系统数据的最终一致性。

## 版本回滚
Nginx的error_page可以实现失败降级：
```nginx
proxy_intercept_errors on;
recursive_error_pages on;
location ~* "^(\d+).html$" {
    proxy_pass http://new_version/$1.html
    error_page 500 502 503 504 =200 /fallback_version/$1.html;
}
```
