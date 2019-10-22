import Control.Monad ( foldM )

safe _ [] _ = True
safe x (x1:xs) n = x /= x1 && x /= x1+n && x /= x1-n && safe x xs (n+1)

queensN n = foldM (\xs _ -> [x:xs | x <- [1..n], safe x xs 1]) [] [1..n]


-- https://www.ituring.com.cn/article/273002