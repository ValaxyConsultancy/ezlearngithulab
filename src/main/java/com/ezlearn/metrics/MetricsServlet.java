package com.ezlearn.metrics;

import io.micrometer.prometheus.PrometheusMeterRegistry;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/metrics")
public class MetricsServlet extends HttpServlet {

    private PrometheusMeterRegistry prometheusRegistry;

    @Override
    public void init() throws ServletException {
        this.prometheusRegistry = (PrometheusMeterRegistry) getServletContext().getAttribute("prometheusRegistry");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/plain");
        resp.getWriter().write(prometheusRegistry.scrape());
    }
}
