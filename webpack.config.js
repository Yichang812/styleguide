'use strict';

const webpack = require('webpack');
const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const MODE =
    process.env.npm_lifecycle_event === "prod" ? "production" : "development";

module.exports = {
    entry: {
        index: [
            './src/index.js'
        ]
    },
    output: {
        path: path.resolve(__dirname, 'public'),
        filename: MODE == "production" ? "[name]-[hash].js" : "index.js",
        publicPath: '/',
    },
    module: {
        noParse: /\.elm$/,
        rules: [
            {
                test: /\.(scss|css)$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    'css-loader',
                    'fast-sass-loader'
                ]
            },
            {
                test: /\.md$/,
                use: 'raw-loader'
            },
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: [
                    { loader: 'elm-hot-webpack-loader' },
                    {
                        loader: 'elm-webpack-loader',
                        options: {
                            debug: true
                        }
                    }
                ]
            },
            {
                test: /\.(ico|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: 'file-loader'
            }
        ]
    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: '[name].css',
            chunkFilename: '[id].css'
        }),
        new webpack.HotModuleReplacementPlugin(),
    ],
    devServer: {
        contentBase: path.join(__dirname, '/'),
        hot: true,
        inline: true,
        port: 9001
    },


};
