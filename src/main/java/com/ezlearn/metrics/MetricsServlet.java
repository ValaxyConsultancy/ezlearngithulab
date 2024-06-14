package com.ezlearn.metrics;

import io.micrometer.prometheus.PrometheusMeterRegistry;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class MetricsServlet extends HttpServlet {

    private final PrometheusMeterRegistry prometheusRegistry;

    public MetricsServlet(PrometheusMeterRegistry prometheusRegistry) {
        this.prometheusRegistry = prometheusRegistry;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/plain");
        resp.getWriter().write(prometheusRegistry.scrape());
    }
}
